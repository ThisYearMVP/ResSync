import React, { useCallback, useState } from "react";
import { View, Text, Pressable, ScrollView } from "react-native";
import { SafeAreaView } from "react-native-safe-area-context";
import { useRouter, useFocusEffect } from "expo-router";
import { LinearGradient } from "expo-linear-gradient";
import { useAuth } from "../../lib/auth";
import { supabase } from "../../lib/supabase";
import { fetchProfileLove, fetchProfileWork } from "../../lib/api";
import {
  MODE_META,
  type TravelMode,
  type ProfileLove,
  type ProfileWork,
} from "../../lib/types";
import { Pill } from "../../components/ui";

export default function ProfileScreen() {
  const { signOut } = useAuth();
  const router = useRouter();
  const [mode, setMode] = useState<TravelMode>("love");
  const [love, setLove] = useState<ProfileLove | null>(null);
  const [work, setWork] = useState<ProfileWork | null>(null);

  const load = useCallback(async () => {
    const { data } = await supabase.auth.getSession();
    const uid = data.session?.user.id;
    if (!uid) return;
    try {
      setLove(await fetchProfileLove(uid));
      setWork(await fetchProfileWork(uid));
    } catch (e) {
      console.warn(e);
    }
  }, []);

  useFocusEffect(
    useCallback(() => {
      load();
    }, [load])
  );

  const meta = MODE_META[mode];
  const incomplete =
    mode === "love" ? !love?.name : !work?.name;

  return (
    <SafeAreaView className="flex-1 bg-bg" edges={["top"]}>
      <ScrollView contentContainerStyle={{ padding: 20 }}>
        <Text className="text-3xl font-extrabold text-textmain mb-5">
          Mon profil
        </Text>

        {/* Switch mode */}
        <View className="flex-row bg-card rounded-full p-1 mb-6">
          {(["love", "work"] as TravelMode[]).map((m) => {
            const active = mode === m;
            return (
              <Pressable
                key={m}
                onPress={() => setMode(m)}
                style={{ flex: 1 }}
              >
                {active ? (
                  <LinearGradient
                    colors={MODE_META[m].gradient}
                    start={{ x: 0, y: 0 }}
                    end={{ x: 1, y: 0 }}
                    style={{
                      borderRadius: 999,
                      paddingVertical: 12,
                      alignItems: "center",
                    }}
                  >
                    <Text className="text-white font-bold">
                      {MODE_META[m].emoji} {MODE_META[m].label}
                    </Text>
                  </LinearGradient>
                ) : (
                  <View className="py-3 items-center">
                    <Text className="text-textsec font-bold">
                      {MODE_META[m].emoji} {MODE_META[m].label}
                    </Text>
                  </View>
                )}
              </Pressable>
            );
          })}
        </View>

        {incomplete ? (
          <View className="bg-card border border-white/10 rounded-2xl p-6 items-center">
            <Text className="text-5xl mb-3">{meta.emoji}</Text>
            <Text className="text-textmain font-bold text-lg mb-1">
              Profil {meta.label} incomplet
            </Text>
            <Text className="text-textsec text-center mb-4">
              {meta.description}
            </Text>
          </View>
        ) : mode === "love" && love ? (
          <View className="bg-card border border-white/10 rounded-2xl p-5">
            <Text className="text-textmain text-2xl font-bold">
              {love.name}, {love.age}
            </Text>
            <Text className="text-textsec mb-3">{love.nationality}</Text>
            <Text className="text-textmain mb-4">{love.bio}</Text>
            <View className="flex-row flex-wrap">
              {love.interests.map((i) => (
                <Pill key={i} label={i} active accent={meta.accent} />
              ))}
            </View>
          </View>
        ) : work ? (
          <View className="bg-card border border-white/10 rounded-2xl p-5">
            <Text className="text-textmain text-2xl font-bold">
              {work.name}
            </Text>
            <Text className="text-textsec mb-3">
              {work.job_title} · {work.company}
            </Text>
            <Text className="text-textmain mb-4">{work.bio_pro}</Text>
            <View className="flex-row flex-wrap">
              {work.skills.map((s) => (
                <Pill key={s} label={s} active accent={meta.accent} />
              ))}
            </View>
          </View>
        ) : null}

        <Pressable
          onPress={() => router.push({ pathname: "/trip/edit-profile", params: { mode } })}
          className="bg-cardlight rounded-2xl py-4 items-center mt-4"
        >
          <Text className="text-majorelle font-bold">
            ✏️ Modifier mon profil {meta.label}
          </Text>
        </Pressable>

        <Pressable
          onPress={signOut}
          className="rounded-2xl py-4 items-center mt-3"
        >
          <Text className="text-red-400 font-semibold">Se déconnecter</Text>
        </Pressable>
      </ScrollView>
    </SafeAreaView>
  );
}
