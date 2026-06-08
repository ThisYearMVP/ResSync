import React from "react";
import { Tabs } from "expo-router";
import { Text } from "react-native";

function Icon({ emoji, color }: { emoji: string; color: string }) {
  return <Text style={{ fontSize: 22, opacity: color === "#6155F5" ? 1 : 0.5 }}>{emoji}</Text>;
}

export default function TabsLayout() {
  return (
    <Tabs
      screenOptions={{
        headerShown: false,
        tabBarActiveTintColor: "#6155F5",
        tabBarInactiveTintColor: "#9A9AB0",
        tabBarStyle: {
          backgroundColor: "#16161F",
          borderTopColor: "rgba(255,255,255,0.06)",
          height: 88,
          paddingTop: 8,
        },
        tabBarLabelStyle: { fontSize: 11, fontWeight: "600" },
      }}
    >
      <Tabs.Screen
        name="trips"
        options={{
          title: "Voyages",
          tabBarIcon: ({ color }) => <Icon emoji="🚆" color={color} />,
        }}
      />
      <Tabs.Screen
        name="messages"
        options={{
          title: "Messages",
          tabBarIcon: ({ color }) => <Icon emoji="💬" color={color} />,
        }}
      />
      <Tabs.Screen
        name="profile"
        options={{
          title: "Profil",
          tabBarIcon: ({ color }) => <Icon emoji="👤" color={color} />,
        }}
      />
    </Tabs>
  );
}
