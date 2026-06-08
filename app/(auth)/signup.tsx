import React, { useState } from "react";
import {
  View,
  Text,
  KeyboardAvoidingView,
  Platform,
  ScrollView,
} from "react-native";
import { Link } from "expo-router";
import { useAuth } from "../../lib/auth";
import { Field, GradientButton } from "../../components/ui";

function strength(pw: string): number {
  let s = 0;
  if (pw.length >= 8) s++;
  if (/[A-Z]/.test(pw)) s++;
  if (/[0-9]/.test(pw)) s++;
  if (/[^A-Za-z0-9]/.test(pw)) s++;
  return s;
}

export default function SignUp() {
  const { signUp } = useAuth();
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState<string | null>(null);
  const [info, setInfo] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);

  const s = strength(password);
  const colors = ["#FF3B30", "#FF9500", "#FFCC00", "#34C759"];

  const onSubmit = async () => {
    setLoading(true);
    setError(null);
    try {
      await signUp(email.trim(), password);
      setInfo("Vérifie tes emails pour confirmer ton compte.");
    } catch (e: any) {
      setError(e.message ?? "Erreur d'inscription");
    } finally {
      setLoading(false);
    }
  };

  return (
    <KeyboardAvoidingView
      behavior={Platform.OS === "ios" ? "padding" : undefined}
      className="flex-1 bg-bg"
    >
      <ScrollView contentContainerStyle={{ flexGrow: 1, justifyContent: "center" }}>
        <View className="px-7">
          <Text className="text-4xl font-extrabold text-textmain mb-1">
            Créer un compte
          </Text>
          <Text className="text-textsec mb-10">
            Rejoins la communauté ResSync.
          </Text>

          <Field
            label="Email"
            value={email}
            onChangeText={setEmail}
            autoCapitalize="none"
            keyboardType="email-address"
            placeholder="toi@email.com"
          />
          <Field
            label="Mot de passe"
            value={password}
            onChangeText={setPassword}
            secureTextEntry
            placeholder="••••••••"
          />

          <View className="flex-row gap-1 mb-4">
            {[0, 1, 2, 3].map((i) => (
              <View
                key={i}
                style={{
                  flex: 1,
                  height: 4,
                  borderRadius: 2,
                  backgroundColor:
                    i < s ? colors[s - 1] : "rgba(255,255,255,0.1)",
                }}
              />
            ))}
          </View>

          {error && <Text className="text-red-400 text-sm mb-3">{error}</Text>}
          {info && <Text className="text-green-400 text-sm mb-3">{info}</Text>}

          <GradientButton
            label="S'inscrire"
            onPress={onSubmit}
            loading={loading}
            disabled={s < 2}
          />

          <View className="flex-row justify-center mt-6">
            <Text className="text-textsec">Déjà un compte ? </Text>
            <Link href="/(auth)/login" className="text-majorelle font-bold">
              Se connecter
            </Link>
          </View>
        </View>
      </ScrollView>
    </KeyboardAvoidingView>
  );
}
