import React, { useState } from "react";
import {
  View,
  Text,
  ScrollView,
  Pressable,
  ActivityIndicator,
  Alert,
} from "react-native";
import { SafeAreaView } from "react-native-safe-area-context";
import { useRouter } from "expo-router";
import * as ImagePicker from "expo-image-picker";
import { LinearGradient } from "expo-linear-gradient";
import { saveUserTrip } from "../../lib/api";
import { scanTicket } from "../../lib/scanner";
import {
  TRANSPORTS,
  ACTIVITIES,
  type TransportType,
  type ActivityType,
} from "../../lib/types";
import { Field, GradientButton, Pill } from "../../components/ui";

export default function AddTrip() {
  const router = useRouter();
  const [origin, setOrigin] = useState("");
  const [destination, setDestination] = useState("");
  const [transport, setTransport] = useState<TransportType>("Train");
  const [activity, setActivity] = useState<ActivityType>("Parler");
  const [saving, setSaving] = useState(false);
  const [scanning, setScanning] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const canSave = origin.trim() && destination.trim();

  const runScan = async (
    launch: () => Promise<ImagePicker.ImagePickerResult>
  ) => {
    setError(null);
    const res = await launch();
    if (res.canceled || !res.assets?.[0]?.base64) return;
    setScanning(true);
    try {
      const ticket = await scanTicket(res.assets[0].base64);
      setOrigin(ticket.origin);
      setDestination(ticket.destination);
      setTransport(ticket.transportType);
      Alert.alert(
        "Billet lu ✅",
        `${ticket.origin} → ${ticket.destination}\n${ticket.trainOrFlightNumber}`
      );
    } catch (e: any) {
      setError(e.message ?? "Scan échoué");
    } finally {
      setScanning(false);
    }
  };

  const scanFromCamera = async () => {
    const perm = await ImagePicker.requestCameraPermissionsAsync();
    if (!perm.granted) {
      setError("Accès caméra refusé.");
      return;
    }
    await runScan(() =>
      ImagePicker.launchCameraAsync({ base64: true, quality: 0.7 })
    );
  };

  const scanFromLibrary = async () => {
    await runScan(() =>
      ImagePicker.launchImageLibraryAsync({ base64: true, quality: 0.7 })
    );
  };

  const onScanPress = () => {
    Alert.alert("Scanner mon billet", "Choisis une source", [
      { text: "📷 Caméra", onPress: scanFromCamera },
      { text: "🖼️ Galerie", onPress: scanFromLibrary },
      { text: "Annuler", style: "cancel" },
    ]);
  };

  const onSave = async () => {
    setSaving(true);
    setError(null);
    try {
      await saveUserTrip({
        origin: origin.trim(),
        destination: destination.trim(),
        date: new Date().toISOString(),
        transport,
        activity,
      });
      router.back();
    } catch (e: any) {
      setError(e.message ?? "Erreur");
    } finally {
      setSaving(false);
    }
  };

  return (
    <SafeAreaView className="flex-1 bg-bg" edges={["top"]}>
      <View className="flex-row items-center px-5 py-3">
        <Pressable onPress={() => router.back()}>
          <Text className="text-majorelle text-base">‹ Retour</Text>
        </Pressable>
      </View>
      <ScrollView contentContainerStyle={{ padding: 20 }}>
        <Text className="text-3xl font-extrabold text-textmain mb-1">
          Nouveau voyage
        </Text>
        <Text className="text-textsec mb-6">Où partons-nous ?</Text>

        {/* Bannière scan billet */}
        <Pressable onPress={onScanPress} disabled={scanning} className="mb-6">
          <LinearGradient
            colors={["#6155F5", "#FF3380"]}
            start={{ x: 0, y: 0 }}
            end={{ x: 1, y: 1 }}
            style={{ borderRadius: 18, padding: 16 }}
          >
            <View className="flex-row items-center">
              <Text className="text-3xl mr-3">🎫</Text>
              <View className="flex-1">
                <Text className="text-white font-bold text-base">
                  Scanner mon billet
                </Text>
                <Text className="text-white/80 text-xs">
                  Photo du billet → infos remplies automatiquement
                </Text>
              </View>
              {scanning ? (
                <ActivityIndicator color="#fff" />
              ) : (
                <Text className="text-white text-xl">›</Text>
              )}
            </View>
          </LinearGradient>
        </Pressable>

        <Field
          label="Départ"
          value={origin}
          onChangeText={setOrigin}
          placeholder="Paris"
        />
        <Field
          label="Destination"
          value={destination}
          onChangeText={setDestination}
          placeholder="Lyon"
        />

        <Text className="text-textsec text-xs font-semibold mb-2 uppercase">
          Transport
        </Text>
        <View className="flex-row mb-5">
          {TRANSPORTS.map((t) => (
            <Pill
              key={t.value}
              label={`${t.icon} ${t.value}`}
              active={transport === t.value}
              onPress={() => setTransport(t.value)}
            />
          ))}
        </View>

        <Text className="text-textsec text-xs font-semibold mb-2 uppercase">
          Activité
        </Text>
        <View className="flex-row flex-wrap mb-6">
          {ACTIVITIES.map((a) => (
            <Pill
              key={a.value}
              label={`${a.icon} ${a.value}`}
              active={activity === a.value}
              onPress={() => setActivity(a.value)}
            />
          ))}
        </View>

        {error && <Text className="text-red-400 mb-3">{error}</Text>}

        <GradientButton
          label="Enregistrer le voyage"
          onPress={onSave}
          loading={saving}
          disabled={!canSave}
        />
      </ScrollView>
    </SafeAreaView>
  );
}
