<template>
	<div class="m-0.5 flex items-start gap-1">
		<div
			ref="grid"
			class="p-0.5 gap-0.5 bg-gray-100 inline-grid grid-cols-10 grid-cols-[repeat(10,50px)] grid-rows-[repeat(10,50px)] shadow"
		>
			<button
				v-for="(cell, i) in cells"
				:id="`button-${i}`"
				:key="i"
				:class="[
					'flex items-center justify-center text-3xl focus:outline-none',
					'border border-dashed focus:border-red-600 focus:bg-red-100 bg-white',
					{ 'bg-blue-100': cell.type === AntType },
				]"
				@focus="focusedCell = cell"
			>
				{{ cell.char }}
			</button>
		</div>
		<div class="grid gap-0.5">
			<Button @click="setAsAnt">Set as Ant</Button>
			<Button @click="moveAnt('ArrowUp')">Up</Button>
			<Button @click="moveAnt('ArrowRight')">Right</Button>
			<Button @click="moveAnt('ArrowDown')">Down</Button>
			<Button @click="moveAnt('ArrowLeft')">Left</Button>
		</div>
	</div>
</template>

<script setup lang="ts">
const EmptyType = Symbol.for("empty");
const CharType = Symbol.for("char");
const AntType = Symbol.for("ant");
type AnyType = typeof EmptyType | typeof CharType | typeof AntType;

type Cell = { type: AnyType; char?: string };
const getEmptyCell = (): Cell => ({ type: EmptyType, char: undefined });
const getCharCell = (char: string): Cell => ({ type: CharType, char });
const getAntCell = (char: string): Cell => ({ type: AntType, char });

const focusedCell = ref<Cell>();
const grid = ref<HTMLElement>();
const cells = ref(
	Array.from({ length: 100 }, (_, index) =>
		54 === index ? getAntCell("🐜") : getEmptyCell()
	)
);
const size = 10;
const arrowCodes = ["ArrowUp", "ArrowRight", "ArrowDown", "ArrowLeft"];
const controllCodes = ["Backspace", "Enter", "Escape"];
const allCodes = [...arrowCodes, ...controllCodes];

const DirectionMap: Record<string, (div: number, mod: number) => number> = {
	ArrowUp: (div, mod) => wrap(div - 1, 0, size) * size + mod,
	ArrowRight: (div, mod) => div * size + wrap(mod + 1, 0, size),
	ArrowDown: (div, mod) => wrap(div + 1, 0, size) * size + mod,
	ArrowLeft: (div, mod) => div * size + wrap(mod - 1, 0, size),
};

function setAsAnt() {
	const cellIndex = cells.value.indexOf(focusedCell.value);
	if (cellIndex < 0) return;

	const remove = (cell: Cell) =>
		cell.type !== AntType ? cell : getCharCell(cell.char);
	const set = (cell: Cell, index: number) =>
		index === cellIndex ? getAntCell(cell.char) : cell;

	cells.value = cells.value.map(remove).map(set);
}

const MoveMap: Record<string, (div: number, mod: number) => number> = {
	ArrowUp: (div, mod) => clamp(div - 1, 0, size - 1) * size + mod,
	ArrowRight: (div, mod) => div * size + clamp(mod + 1, 0, size - 1),
	ArrowDown: (div, mod) => clamp(div + 1, 0, size - 1) * size + mod,
	ArrowLeft: (div, mod) => div * size + clamp(mod - 1, 0, size - 1),
};

function moveAnt(direction: string) {
	const antIndex = cells.value.findIndex((cell) => cell.type === AntType);
	if (antIndex < 0) return;
	const { div, mod } = getDivMode(antIndex);
	const newIndex = MoveMap[direction](div, mod);
	if (antIndex === newIndex) return;
	const [first, last] = sort([antIndex, newIndex]);
	cells.value = swapItems(cells.value, first, last);
}

function getChar() {
	const text = window.prompt();
	if (!text) return;
	const [firstSymbol] = Array.from(text);
	return firstSymbol.length !== 1 ? firstSymbol : firstSymbol.toUpperCase();
}

onMounted(() => {
	const doc = grid.value.ownerDocument;
	function listener(e: KeyboardEvent) {
		if (document.activeElement.parentElement === grid.value) return;
		if (!arrowCodes.includes(e.code)) return;
		moveAnt(e.code);
	}
	doc.addEventListener("keydown", listener);
	onUnmounted(() => doc.removeEventListener("keydown", listener));
});

onMounted(() => {
	const doc = grid.value.ownerDocument;

	function listener(e: KeyboardEvent) {
		if (doc.activeElement.parentElement !== grid.value) return;
		if (!allCodes.includes(e.code)) return;

		const children = [...grid.value.querySelectorAll("button")];
		const focusElement = children.find((c) => c === doc.activeElement);
		const focusIndex = children.indexOf(focusElement);

		if (e.code === "Escape") {
			focusElement.blur();
			return;
		}

		if (e.code === "Backspace") {
			cells.value[focusIndex] = getEmptyCell();
			return;
		}

		if (e.code === "Enter") {
			cells.value[focusIndex] = getCharCell(getChar());
			return;
		}

		const { div, mod } = getDivMode(focusIndex);
		const nextIndex = DirectionMap[e.code](div, mod);
		const selector = `:scope button:nth-child(${nextIndex + 1})`;
		const button = grid.value.querySelector<HTMLElement>(selector);
		button.focus();
	}

	doc.addEventListener("keydown", listener);
	onUnmounted(() => doc.removeEventListener("keydown", listener));
});

function wrap(num: number, min: number, max: number): number {
	const rangeSize = max - min;
	return ((((num - min) % rangeSize) + rangeSize) % rangeSize) + min;
}

function clamp(val: number, min: number = 0, max: number = 1): number {
	return Math.max(min, Math.min(max, val));
}

const swapItems = <T, _>(a: T[], i: number, j: number): T[] =>
	(a[i] &&
		a[j] && [
			...a.slice(0, i),
			a[j],
			...a.slice(i + 1, j),
			a[i],
			...a.slice(j + 1),
		]) ||
	a;

const sort = (arr: number[]): number[] => arr.sort((a, b) => a - b);

function getDivMode(n: number) {
	const div = Math.floor(n / size);
	const mod = n % size;
	return { div, mod };
}

function Button(props: any, { slots }) {
	const { class: className, ...rest } = props;
	const classes = ["bg-gray-100 px-4 py-2 rounded", className];
	const newProps = { ...rest, class: classes };
	return h("button", newProps, slots);
}
</script>
