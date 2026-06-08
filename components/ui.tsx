import React from "react";
import {
  Text,
  TextInput,
  Pressable,
  View,
  ActivityIndicator,
  TextInputProps,
} from "react-native";
import { LinearGradient } from "expo-linear-gradient";

// ── Bouton plein avec dégradé ──────────────────────────────────
export function GradientButton({
  label,
  onPress,
  colors = ["#6155F5", "#6155F5"],
  loading = false,
  disabled = false,
}: {
  label: string;
  onPress: () => void;
  colors?: [string, string];
  loading?: boolean;
  disabled?: boolean;
}) {
  return (
    <Pressable
      onPress={onPress}
      disabled={disabled || loading}
      style={{ opacity: disabled ? 0.4 : 1 }}
    >
      <LinearGradient
        colors={colors}
        start={{ x: 0, y: 0 }}
        end={{ x: 1, y: 1 }}
        style={{
          borderRadius: 16,
          paddingVertical: 16,
          alignItems: "center",
        }}
      >
        {loading ? (
          <ActivityIndicator color="#fff" />
        ) : (
          <Text className="text-white font-bold text-base">{label}</Text>
        )}
      </LinearGradient>
    </Pressable>
  );
}

// ── Champ texte stylé ──────────────────────────────────────────
export function Field({
  label,
  ...props
}: { label: string } & TextInputProps) {
  return (
    <View className="mb-4">
      <Text className="text-textsec text-xs font-semibold mb-2 uppercase">
        {label}
      </Text>
      <TextInput
        placeholderTextColor="#6A6A80"
        className="bg-cardlight text-textmain px-4 py-3 rounded-xl text-base"
        {...props}
      />
    </View>
  );
}

// ── Carte glassmorphism ────────────────────────────────────────
export function Card({
  children,
  className = "",
}: {
  children: React.ReactNode;
  className?: string;
}) {
  return (
    <View
      className={`bg-card border border-white/10 rounded-2xl p-4 ${className}`}
    >
      {children}
    </View>
  );
}

// ── Pill / tag ─────────────────────────────────────────────────
export function Pill({
  label,
  active = false,
  onPress,
  accent = "#6155F5",
}: {
  label: string;
  active?: boolean;
  onPress?: () => void;
  accent?: string;
}) {
  return (
    <Pressable
      onPress={onPress}
      style={{
        backgroundColor: active ? accent : "rgba(255,255,255,0.08)",
        borderRadius: 999,
        paddingHorizontal: 14,
        paddingVertical: 8,
        margin: 4,
      }}
    >
      <Text style={{ color: active ? "#fff" : "#9A9AB0", fontWeight: "600" }}>
        {label}
      </Text>
    </Pressable>
  );
}
