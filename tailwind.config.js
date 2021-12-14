/** @type {import('tailwindcss/tailwind-config').TailwindConfig} */
module.exports = {
	content: [
		`./components/**/*.{vue,js,ts}`,
		`./layouts/**/*.vue`,
		`./pages/**/*.vue`,
		`./plugins/**/*.{js,ts}`,
		`./nuxt.config.ts`,
	],
	plugins: [require("@tailwindcss/forms")],
};
