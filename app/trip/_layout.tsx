import { Stack } from "expo-router";

export default function TripLayout() {
  return (
    <Stack
      screenOptions={{
        headerShown: false,
        contentStyle: { backgroundColor: "#0B0B14" },
        presentation: "card",
      }}
    />
  );
}
