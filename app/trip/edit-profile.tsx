import React, { useEffect, useState } from "react";
import { View, Text, ScrollView, Pressable } from "react-native";
import { SafeAreaView } from "react-native-safe-area-context";
import { useLocalSearchParams, useRouter } from "expo-router";
import { supabase } from "../../lib/supabase";
import {
  fetchProfileLove,
  fetchProfileWork,
  saveProfileLove,
  saveProfileWork,
} from "../../lib/api";
import {
  emptyLove,
  emptyWork,
  MODE_META,
  type TravelMode,
  type ProfileLove,
  type ProfileWork,
} from "../../lib/types";
import { Field, GradientButton, Pill } from "../../components/ui";

const LOVE_INTERESTS = [
  "Voyage", "Musique", "Sport", "Cuisine", "Cinéma", "Lecture",
  "Art", "Nature", "Tech", "Photo", "Danse", "Jeux",
];
const WORK_SKILLS = [
  "Dev", "Design", "Marketing", "Finance", "Vente", "RH",
  "Data", "Produit", "Légal", "Conseil", "Ops", "Stratégie",
];

export default function EditProfile() {
  const { mode } = useLocalSearchParams<{ mode: TravelMode }>();
  const m: TravelMode = mode === "work" ? "work" : "love";
  const router = useRouter();
  const meta = MODE_META[m];

  const [love, setLove] = useState<ProfileLove>(emptyLove());
  const [work, setWork] = useState<ProfileWork>(emptyWork());
  const [saving, setSaving] = useState(false);

  useEffect(() => {
    (async () => {
      const { data } = await supabase.auth.getSession();
      const uid = data.session?.user.id;
      if (!uid) return;
      if (m === "love") {
        const p = await fetchProfileLove(uid);
        if (p) setLove(p);
      } else {
        const p = await fetchProfileWork(uid);
        if (p) setWork(p);
      }
    })();
  }, [m]);

  const toggle = (arr: string[], v: string, max: number) =>
    arr.includes(v)
      ? arr.filter((x) => x !== v)
      : arr.length < max
      ? [...arr, v]
      : arr;

  const onSave = async () => {
    setSaving(true);
    try {
      if (m === "love") await saveProfileLove(love);
      else await saveProfileWork(work);
      router.back();
    } catch (e) {
      console.warn(e);
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
          {meta.emoji} Profil {meta.label}
        </Text>
        <Text className="text-textsec mb-6">{meta.description}</Text>

        {m === "love" ? (
          <>
            <Field
              label="Prénom"
              value={love.name}
              onChangeText={(t) => setLove({ ...love, name: t })}
            />
            <Field
              label="Âge"
              value={String(love.age)}
              keyboardType="number-pad"
              onChangeText={(t) =>
                setLove({ ...love, age: parseInt(t || "0", 10) || 0 })
              }
            />
            <Field
              label="Nationalité"
              value={love.nationality}
              onChangeText={(t) => setLove({ ...love, nationality: t })}
            />
            <Field
              label="Bio"
              value={love.bio}
              multiline
              onChangeText={(t) => setLove({ ...love, bio: t })}
            />
            <Text className="text-textsec text-xs font-semibold mb-2 uppercase">
              Centres d'intérêt (max 6)
            </Text>
            <View className="flex-row flex-wrap mb-6">
              {LOVE_INTERESTS.map((i) => (
                <Pill
                  key={i}
                  label={i}
                  active={love.interests.includes(i)}
                  accent={meta.accent}
                  onPress={() =>
                    setLove({
                      ...love,
                      interests: toggle(love.interests, i, 6),
                    })
                  }
                />
              ))}
            </View>
          </>
        ) : (
          <>
            <Field
              label="Nom"
              value={work.name}
              onChangeText={(t) => setWork({ ...work, name: t })}
            />
            <Field
              label="Poste"
              value={work.job_title}
              onChangeText={(t) => setWork({ ...work, job_title: t })}
            />
            <Field
              label="Entreprise"
              value={work.company}
              onChangeText={(t) => setWork({ ...work, company: t })}
            />
            <Field
              label="Bio pro"
              value={work.bio_pro}
              multiline
              onChangeText={(t) => setWork({ ...work, bio_pro: t })}
            />
            <Text className="text-textsec text-xs font-semibold mb-2 uppercase">
              Compétences (max 8)
            </Text>
            <View className="flex-row flex-wrap mb-6">
              {WORK_SKILLS.map((s) => (
                <Pill
                  key={s}
                  label={s}
                  active={work.skills.includes(s)}
                  accent={meta.accent}
                  onPress={() =>
                    setWork({ ...work, skills: toggle(work.skills, s, 8) })
                  }
                />
              ))}
            </View>
          </>
        )}

        <GradientButton
          label="Enregistrer"
          onPress={onSave}
          loading={saving}
          colors={meta.gradient}
        />
      </ScrollView>
    </SafeAreaView>
  );
}
