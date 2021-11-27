import { defineNuxtConfig } from "nuxt3";
import CopyPlugin from 'copy-webpack-plugin';
import path from 'path'

const elements = ['field', 'block', 'category', 'xml', 'mutation', 'value', 'sep', 'shadow']

// https://v3.nuxtjs.org/docs/directory-structure/nuxt.config
export default defineNuxtConfig({
	ssr: false,
	css: ["tailwindcss/tailwind.css"],
	build: {
		postcss: {
			postcssOptions: require("./postcss.config.js"),
		},
		plugins: [
			new CopyPlugin({
				patterns: [{
					from: path.resolve(__dirname, './node_modules/blockly/media'),
					to: path.resolve(__dirname, 'public/media')
				}]
			})
		],
	},
	vue: {
		compilerOptions: {
			isCustomElement: (tag) => elements.includes(tag)
		},
		config: {
			productionTip: false,
			ignoredElements: elements
		}
	}
});
