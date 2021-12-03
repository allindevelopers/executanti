<template>
	<div
		ref="grid"
		class="p-0.5 gap-0.5 grid grid-cols-10 grid-cols-[repeat(10,50px)] grid-rows-[repeat(10,50px)]"
	>
		<button
			:id="`button-${i}`"
			v-for="(cell, i) in cells"
			@click="editCell(i)"
			:key="i"
			:class="[
				'flex items-center justify-center text-3xl focus:outline-none',
				'border border-dashed focus:border-red-600 focus:bg-red-100',
			]"
		>
			{{ cell }}
		</button>
	</div>
</template>

<script setup lang="ts">
const grid = ref<HTMLElement>();
const cells = ref(Array.from({ length: 100 }));

function editCell(index) {
	const text = window.prompt();
	if (!text) return;
	const firstSymbol = String.fromCodePoint(text.codePointAt(0));
	cells.value[index] =
		firstSymbol.length !== 1 ? firstSymbol : firstSymbol.toUpperCase();
}

onMounted(() => {
	const doc = grid.value.ownerDocument;
	const size = 10;
	const codes = [
		"ArrowUp",
		"ArrowRight",
		"ArrowDown",
		"ArrowLeft",
		"Backspace",
	];

	const map: Record<string, (div: number, mod: number) => number> = {
		ArrowUp: (div, mod) => rotate(div - 1, 0, size) * size + mod,
		ArrowRight: (div, mod) => div * size + rotate(mod + 1, 0, size),
		ArrowDown: (div, mod) => rotate(div + 1, 0, size) * size + mod,
		ArrowLeft: (div, mod) => div * size + rotate(mod - 1, 0, size),
	};

	function listener(e: KeyboardEvent) {
		if (document.activeElement.parentElement !== grid.value) return;
		if (!codes.includes(e.code)) return;

		const children = [...grid.value.children];
		const focusIndex = children.indexOf(document.activeElement);

		if (e.code === "Backspace") {
			cells.value[focusIndex] = "";
			return;
		}

		const div = Math.floor(focusIndex / size);
		const mod = focusIndex % size;
		const index = map[e.code](div, mod);
		const selector = `:scope button:nth-child(${index + 1})`;
		const button = grid.value.querySelector<HTMLElement>(selector);
		button.focus();
	}

	doc.addEventListener("keydown", listener);
	onUnmounted(() => doc.removeEventListener("keydown", listener));
});

const clamp = (val: number, min: number = 0, max: number = 1): number =>
	Math.max(min, Math.min(max, val));

const rotate = (val: number, min: number = 0, max: number = 1): number =>
	val < min ? val + max : val % max;
</script>
