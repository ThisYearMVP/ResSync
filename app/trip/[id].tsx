import React, { useState } from "react";
import {
  View,
  Text,
  Pressable,
  FlatList,
  ActivityIndicator,
  Alert,
} from "react-native";
import { SafeAreaView } from "react-native-safe-area-context";
import { useLocalSearchParams, useRouter } from "expo-router";
import { LinearGradient } from "expo-linear-gradient";
import { Image } from "expo-image";
import { joinTrip, loadTripPeople, sendReaction } from "../../lib/api";
import {
  MODE_META,
  REACTIONS,
  type TravelMode,
  type TripParticipant,
} from "../../lib/types";

export default function TripDetail() {
  const { id, origin, destination } = useLocalSearchParams<{
    id: string;
    origin?: string;
    destination?: string;
  }>();
  const router = useRouter();
  const [mode, setMode] = useState<TravelMode | null>(null);
  const [people, setPeople] = useState<TripParticipant[]>([]);
  const [loading, setLoading] = useState(false);

  const enter = async (m: TravelMode) => {
    setMode(m);
    setLoading(true);
    try {
      await joinTrip(id, m);
      setPeople(await loadTripPeople(id, m));
    } catch (e) {
      console.warn(e);
    } finally {
      setLoading(false);
    }
  };

  const react = async (p: TripParticipant, r: (typeof REACTIONS)[number]) => {
    try {
      await sendReaction(id, p.user_id, r.value);
      Alert.alert("Envoyé !", `${r.emoji} envoyé.`);
    } catch (e: any) {
      Alert.alert("Oups", e.message ?? "Erreur");
    }
  };

  // ── Mode picker ──────────────────────────────────────────────
  if (!mode) {
    return (
      <SafeAreaView className="flex-1 bg-bg" edges={["top"]}>
        <View className="flex-row items-center px-5 py-3">
          <Pressable onPress={() => router.back()}>
            <Text className="text-majorelle text-base">‹ Retour</Text>
          </Pressable>
        </View>
        <View className="flex-1 px-6 justify-center">
          <Text className="text-textsec text-center mb-1">
            {origin} → {destination}
          </Text>
          <Text className="text-textmain text-2xl font-extrabold text-center mb-8">
            Comment voyages-tu ?
          </Text>
          {(["love", "work"] as TravelMode[]).map((m) => (
            <Pressable key={m} onPress={() => enter(m)} className="mb-4">
              <LinearGradient
                colors={MODE_META[m].gradient}
                start={{ x: 0, y: 0 }}
                end={{ x: 1, y: 1 }}
                style={{ borderRadius: 24, padding: 24 }}
              >
                <Text className="text-white text-3xl mb-2">
                  {MODE_META[m].emoji}
                </Text>
                <Text className="text-white text-xl font-bold">
                  {MODE_META[m].label}
                </Text>
                <Text className="text-white/80">{MODE_META[m].description}</Text>
              </LinearGradient>
            </Pressable>
          ))}
        </View>
      </SafeAreaView>
    );
  }

  // ── People grid ──────────────────────────────────────────────
  const meta = MODE_META[mode];
  return (
    <SafeAreaView className="flex-1 bg-bg" edges={["top"]}>
      <View className="flex-row items-center justify-between px-5 py-3">
        <Pressable onPress={() => setMode(null)}>
          <Text className="text-majorelle text-base">‹ Mode</Text>
        </Pressable>
        <Text className="text-textmain font-bold">
          {meta.emoji} {origin} → {destination}
        </Text>
        <View style={{ width: 50 }} />
      </View>

      {loading ? (
        <ActivityIndicator color="#6155F5" className="mt-10" />
      ) : (
        <FlatList
          data={people}
          keyExtractor={(p) => p.user_id}
          numColumns={2}
          contentContainerStyle={{ padding: 12 }}
          columnWrapperStyle={{ gap: 12 }}
          ListEmptyComponent={
            <View className="items-center mt-20">
              <Text className="text-5xl mb-3">🫥</Text>
              <Text className="text-textsec text-center px-10">
                Personne d'autre n'a encore rejoint ce voyage en mode{" "}
                {meta.label}.
              </Text>
            </View>
          }
          renderItem={({ item }) => {
            const lp = item.profileLove;
            const wp = item.profileWork;
            const name = mode === "love" ? lp?.name : wp?.name;
            const subtitle =
              mode === "love"
                ? lp
                  ? `${lp.age} · ${lp.nationality}`
                  : ""
                : wp
                ? wp.job_title
                : "";
            const photo =
              mode === "love" ? lp?.photos?.[0] : wp?.photo;
            return (
              <View
                className="flex-1 bg-card border border-white/10 rounded-2xl overflow-hidden mb-3"
                style={{ maxWidth: "48%" }}
              >
                <View className="h-36 bg-cardlight items-center justify-center">
                  {photo ? (
                    <Image
                      source={{ uri: photo }}
                      style={{ width: "100%", height: "100%" }}
                      contentFit="cover"
                    />
                  ) : (
                    <Text className="text-4xl">{meta.emoji}</Text>
                  )}
                </View>
                <View className="p-3">
                  <Text className="text-textmain font-bold" numberOfLines={1}>
                    {name ?? "Voyageur"}
                  </Text>
                  <Text className="text-textsec text-xs mb-2" numberOfLines={1}>
                    {subtitle}
                  </Text>
                  <View className="flex-row justify-between">
                    {REACTIONS.map((r) => (
                      <Pressable
                        key={r.value}
                        onPress={() => react(item, r)}
                        className="bg-cardlight rounded-full w-9 h-9 items-center justify-center"
                      >
                        <Text className="text-base">{r.emoji}</Text>
                      </Pressable>
                    ))}
                  </View>
                </View>
              </View>
            );
          }}
        />
      )}
    </SafeAreaView>
  );
}
