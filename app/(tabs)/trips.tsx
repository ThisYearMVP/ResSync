import React, { useCallback, useState } from "react";
import {
  View,
  Text,
  FlatList,
  Pressable,
  RefreshControl,
  ActivityIndicator,
} from "react-native";
import { useRouter, useFocusEffect } from "expo-router";
import { SafeAreaView } from "react-native-safe-area-context";
import { fetchUserTrips } from "../../lib/api";
import type { Trip } from "../../lib/types";
import { TRANSPORTS, ACTIVITIES } from "../../lib/types";

function formatDate(iso: string) {
  try {
    return new Date(iso).toLocaleDateString("fr-FR", {
      weekday: "short",
      day: "numeric",
      month: "short",
      hour: "2-digit",
      minute: "2-digit",
    });
  } catch {
    return iso;
  }
}

function TripCard({ trip, onPress }: { trip: Trip; onPress: () => void }) {
  const tIcon = TRANSPORTS.find((t) => t.value === trip.transport)?.icon ?? "🚆";
  const aIcon = ACTIVITIES.find((a) => a.value === trip.activity)?.icon ?? "✨";
  return (
    <Pressable
      onPress={onPress}
      className="bg-card border border-white/10 rounded-2xl p-4 mb-3"
    >
      <View className="flex-row items-center justify-between mb-2">
        <Text className="text-2xl">{tIcon}</Text>
        <Text className="text-textsec text-xs">{formatDate(trip.date)}</Text>
      </View>
      <View className="flex-row items-center">
        <Text className="text-textmain text-lg font-bold">{trip.origin}</Text>
        <Text className="text-majorelle mx-2 text-lg">→</Text>
        <Text className="text-textmain text-lg font-bold">
          {trip.destination}
        </Text>
      </View>
      <View className="flex-row items-center mt-2">
        <Text className="text-textsec text-sm">
          {aIcon} {trip.activity}
        </Text>
      </View>
    </Pressable>
  );
}

export default function TripsScreen() {
  const router = useRouter();
  const [trips, setTrips] = useState<Trip[]>([]);
  const [loading, setLoading] = useState(true);

  const load = useCallback(async () => {
    setLoading(true);
    try {
      setTrips(await fetchUserTrips());
    } catch (e) {
      console.warn(e);
    } finally {
      setLoading(false);
    }
  }, []);

  useFocusEffect(
    useCallback(() => {
      load();
    }, [load])
  );

  return (
    <SafeAreaView className="flex-1 bg-bg" edges={["top"]}>
      <View className="flex-row items-center justify-between px-5 pt-2 pb-4">
        <Text className="text-3xl font-extrabold text-textmain">
          Mes voyages
        </Text>
        <Pressable
          onPress={() => router.push("/trip/add")}
          className="bg-majorelle w-11 h-11 rounded-full items-center justify-center"
        >
          <Text className="text-white text-2xl -mt-0.5">+</Text>
        </Pressable>
      </View>

      {loading ? (
        <ActivityIndicator color="#6155F5" className="mt-10" />
      ) : (
        <FlatList
          data={trips}
          keyExtractor={(t) => t.id}
          contentContainerStyle={{ padding: 20, paddingTop: 0 }}
          refreshControl={
            <RefreshControl refreshing={false} onRefresh={load} tintColor="#6155F5" />
          }
          ListEmptyComponent={
            <View className="items-center mt-20">
              <Text className="text-6xl mb-4">🧳</Text>
              <Text className="text-textsec text-center">
                Aucun voyage.{"\n"}Ajoute ton premier trajet !
              </Text>
            </View>
          }
          renderItem={({ item }) => (
            <TripCard
              trip={item}
              onPress={() =>
                router.push({
                  pathname: "/trip/[id]",
                  params: {
                    id: item.id,
                    origin: item.origin,
                    destination: item.destination,
                  },
                })
              }
            />
          )}
        />
      )}
    </SafeAreaView>
  );
}
