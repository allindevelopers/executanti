<template>
	<div
		class="p-0.5 gap-0.5 grid grid-cols-10 grid-cols-[repeat(10,50px)] grid-rows-[repeat(10,50px)]"
	>
		<button
			v-for="(cell, i) in cells"
			:key="i"
			:class="[
				'flex items-center justify-center',
				'border border-dashed text-3xl focus:outline-none focus:border-red-600 focus:bg-red-100',
			]"
			@click="editCell(i)"
		>
			{{ cell }}
		</button>
	</div>
</template>

<script setup>
const cells = ref(Array.from({ length: 100 }));

function editCell(index) {
	const text = window.prompt();
	if (!text) return;
	const firstSymbol = String.fromCodePoint(text.codePointAt(0));
	console.log(firstSymbol.length);
	cells.value[index] =
		firstSymbol.length !== 1 ? firstSymbol : firstSymbol.toUpperCase();
}
</script>
