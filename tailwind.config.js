/** @type {import('tailwindcss/tailwind-config').TailwindConfig} */
module.exports = {
	mode: "jit",
	purge: {
		content: [
			`./components/**/*.{vue,js,ts}`,
			`./layouts/**/*.vue`,
			`./pages/**/*.vue`,
			`./plugins/**/*.{js,ts}`,
			`./nuxt.config.ts`,
		],
	},
	darkMode: false, // or 'media' or 'class'
};
