module.exports = function (api) {
  api.cache(true);
  return {
    presets: [
      ["babel-preset-expo", { jsxImportSource: "nativewind" }],
      "nativewind/babel",
    ],
    // reanimated 4 : le plugin worklets est ajouté par nativewind/babel
    plugins: [],
  };
};
