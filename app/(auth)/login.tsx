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

export default function Login() {
  const { signIn } = useAuth();
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);

  const onSubmit = async () => {
    setLoading(true);
    setError(null);
    try {
      await signIn(email.trim(), password);
    } catch (e: any) {
      setError(e.message ?? "Erreur de connexion");
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
          <Text className="text-5xl font-extrabold text-textmain mb-1">
            ResSync
          </Text>
          <Text className="text-textsec mb-10">
            Rencontre les gens de ton voyage.
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

          {error && (
            <Text className="text-red-400 text-sm mb-3">{error}</Text>
          )}

          <GradientButton
            label="Se connecter"
            onPress={onSubmit}
            loading={loading}
          />

          <View className="flex-row justify-center mt-6">
            <Text className="text-textsec">Pas de compte ? </Text>
            <Link href="/(auth)/signup" className="text-majorelle font-bold">
              S'inscrire
            </Link>
          </View>
        </View>
      </ScrollView>
    </KeyboardAvoidingView>
  );
}
