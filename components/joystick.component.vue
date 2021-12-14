<template>
	<div
		class="grid gap-px grid-cols-[repeat(3,50px)] grid-rows-[repeat(3,50px)] text-3xl place-content-center"
		v-bind="$attrs"
	>
		<div></div>
		<Button @click="$emit('click', 'ArrowUp')">
			<svg
				xmlns="http://www.w3.org/2000/svg"
				class="h-8 w-8"
				viewBox="0 0 20 20"
				fill="currentColor"
			>
				<path
					fill-rule="evenodd"
					d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-8.707l-3-3a1 1 0 00-1.414 0l-3 3a1 1 0 001.414 1.414L9 9.414V13a1 1 0 102 0V9.414l1.293 1.293a1 1 0 001.414-1.414z"
					clip-rule="evenodd"
				/>
			</svg>
		</Button>
		<div></div>
		<Button @click="$emit('click', 'ArrowLeft')">
			<svg
				xmlns="http://www.w3.org/2000/svg"
				class="h-8 w-8"
				viewBox="0 0 20 20"
				fill="currentColor"
			>
				<path
					fill-rule="evenodd"
					d="M10 18a8 8 0 100-16 8 8 0 000 16zm.707-10.293a1 1 0 00-1.414-1.414l-3 3a1 1 0 000 1.414l3 3a1 1 0 001.414-1.414L9.414 11H13a1 1 0 100-2H9.414l1.293-1.293z"
					clip-rule="evenodd"
				/>
			</svg>
		</Button>
		<button
			class="flex items-center justify-center text-gray-400 cursor-[grab]"
		>
			<svg
				xmlns="http://www.w3.org/2000/svg"
				class="h-6 w-6 mt-2"
				fill="none"
				viewBox="0 0 24 24"
				stroke="currentColor"
			>
				<path
					stroke-linecap="round"
					stroke-linejoin="round"
					stroke-width="2"
					d="M4 8V4m0 0h4M4 4l5 5m11-1V4m0 0h-4m4 0l-5 5M4 16v4m0 0h4m-4 0l5-5m11 5l-5-5m5 5v-4m0 4h-4"
				/>
			</svg>
		</button>
		<Button @click="$emit('click', 'ArrowRight')">
			<svg
				xmlns="http://www.w3.org/2000/svg"
				class="h-8 w-8"
				viewBox="0 0 20 20"
				fill="currentColor"
			>
				<path
					fill-rule="evenodd"
					d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-8.707l-3-3a1 1 0 00-1.414 1.414L10.586 9H7a1 1 0 100 2h3.586l-1.293 1.293a1 1 0 101.414 1.414l3-3a1 1 0 000-1.414z"
					clip-rule="evenodd"
				/>
			</svg>
		</Button>
		<div></div>
		<Button @click="$emit('click', 'ArrowDown')">
			<svg
				xmlns="http://www.w3.org/2000/svg"
				class="h-8 w-8"
				viewBox="0 0 20 20"
				fill="currentColor"
			>
				<path
					fill-rule="evenodd"
					d="M10 18a8 8 0 100-16 8 8 0 000 16zm1-11a1 1 0 10-2 0v3.586L7.707 9.293a1 1 0 00-1.414 1.414l3 3a1 1 0 001.414 0l3-3a1 1 0 00-1.414-1.414L11 10.586V7z"
					clip-rule="evenodd"
				/>
			</svg>
		</Button>
		<div></div>
	</div>
</template>

<script lang="ts">
import { defineComponent } from "vue";

export default defineComponent({
	inheritAttrs: false,
	components: { Button },
	emits: ["click"],
});

function Button(props: any, { slots }) {
	const { class: className, ...rest } = props;
	const classes = [
		"bg-white rounded-xl hover:bg-gray-50 shadow-md active:shadow flex items-center justify-center text-yellow-400",
		className,
	];
	const newProps = { ...rest, class: classes };
	return h("button", newProps, slots);
}
</script>
