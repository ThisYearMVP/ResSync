/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ["./app/**/*.{js,jsx,ts,tsx}", "./components/**/*.{js,jsx,ts,tsx}"],
  presets: [require("nativewind/preset")],
  theme: {
    extend: {
      colors: {
        bg: "#0B0B14",
        card: "#16161F",
        cardlight: "#1F1F2B",
        majorelle: "#6155F5",
        love1: "#FF734D",
        love2: "#FF3380",
        loveAccent: "#FFCC1A",
        work1: "#2659E6",
        work2: "#0D268C",
        workAccent: "#3380FF",
        textmain: "#F5F5FA",
        textsec: "#9A9AB0",
      },
    },
  },
  plugins: [],
};
