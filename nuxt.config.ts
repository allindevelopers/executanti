import { defineNuxtConfig } from "nuxt3";

// https://v3.nuxtjs.org/docs/directory-structure/nuxt.config
export default defineNuxtConfig({
	css: ["tailwindcss/tailwind.css"],
	build: {
		postcss: {
			postcssOptions: require("./postcss.config.js"),
		},
	},
	meta: {
		title: "Ant",
		charset: "utf-8",
		meta: [
			{
				name: "viewport",
				content: "width=device-width, initial-scale=1",
			},
		],
		link: [
			{
				rel: "icon",
				type: "image/x-icon",
				href: "https://fav.farm/%F0%9F%90%9C",
			},
		],
	},
});
