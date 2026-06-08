import React from "react";
import { View, Text } from "react-native";
import { SafeAreaView } from "react-native-safe-area-context";

export default function MessagesScreen() {
  return (
    <SafeAreaView className="flex-1 bg-bg" edges={["top"]}>
      <Text className="text-3xl font-extrabold text-textmain px-5 pt-2 pb-4">
        Messages
      </Text>
      <View className="flex-1 items-center justify-center px-10">
        <Text className="text-6xl mb-4">💬</Text>
        <Text className="text-textsec text-center">
          Tes conversations apparaîtront ici quand tu auras réagi à quelqu'un
          sur un voyage.
        </Text>
      </View>
    </SafeAreaView>
  );
}
