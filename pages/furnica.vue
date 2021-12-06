<template>
	<Container>
		<div class="mt-4 mx-auto flex p-px gap-px max-w-max bg-gray-200">
			<textarea
				class="flex-grow p-4 font-mono uppercase resize-none overflow-x-scroll"
				placeholder="TODO: Code goes here..."
			></textarea>
			<div class="grid gap-px place-content-start">
				<Button>Begin</Button>
				<Button>End</Button>
				<Button>Up</Button>
				<Button>Down</Button>
				<Button>Right</Button>
				<Button>Left</Button>
				<Button>While</Button>
				<Button>Do</Button>
				<Button>Repeat</Button>
				<Button>Times</Button>
				<Button>If</Button>
				<Button>Then</Button>
				<Button>Else</Button>
				<Button>Is edge</Button>
				<Button>Is not edge</Button>
				<Button>Procedure</Button>
				<Button>End ...</Button>
			</div>
			<div class="grid gap-px">
				<div
					ref="grid"
					class="grid gap-px grid-cols-10 grid-cols-[repeat(10,50px)] grid-rows-[repeat(10,50px)]"
				>
					<button
						v-for="(cell, i) in cells"
						:id="`button-${i}`"
						:key="i"
						:class="[
							'flex items-center justify-center text-3xl focus:outline-none',
							'bg-white focus:bg-red-100',
							{ 'bg-blue-100': cell.type === AntType },
						]"
						@focus="focusedCell = cell"
					>
						{{ cell.char }}
					</button>
				</div>
				<div class="flex gap-px place-content-stretch">
					<Button @click="setAsAnt">Set as Ant</Button>
					<Button @click="moveAnt('ArrowUp')">Up</Button>
					<Button @click="moveAnt('ArrowRight')">Right</Button>
					<Button @click="moveAnt('ArrowDown')">Down</Button>
					<Button @click="moveAnt('ArrowLeft')">Left</Button>
					<Button @click="clearBoard">Clear Board</Button>
				</div>
			</div>
		</div>
	</Container>
</template>

<script setup lang="ts">
import { FunctionalComponent } from "vue";
const EmptyType = Symbol.for("empty");
const CharType = Symbol.for("char");
const AntType = Symbol.for("ant");
type AnyType = typeof EmptyType | typeof CharType | typeof AntType;

type Cell = { type: AnyType; char?: string };
const getEmptyCell = (): Cell => ({ type: EmptyType, char: undefined });
const getCharCell = (char: string): Cell => ({ type: CharType, char });
const getAntCell = (char: string): Cell => ({ type: AntType, char });

type CreateGridProps = {
	antIndex?: number;
	size?: number;
	letters?: Record<number, string>;
};
function createGrid(props: CreateGridProps = {}) {
	const { antIndex, size = 10, letters = {} } = props;
	return Array.from({ length: size * size }, (_, index) => {
		if (antIndex === index) return getAntCell("🐜");
		if (letters[index]) return getCharCell(letters[index]);
		return getEmptyCell();
	});
}

const letters = { 52: "A", 53: "N", 54: "T" };

const focusedCell = ref<Cell>();
const grid = ref<HTMLElement>();
const cells = ref(createGrid({ antIndex: 11, letters }));
const size = 10;
type ArrowCodes = typeof arrowCodes[number];
const arrowCodes = ["ArrowUp", "ArrowRight", "ArrowDown", "ArrowLeft"] as const;
const controllCodes = ["Backspace", "Enter", "Escape"] as const;
const allCodes = [...arrowCodes, ...controllCodes];

// Move to other side of the grid when margin
const WrapMap: Record<ArrowCodes, (index: number) => number> = {
	ArrowUp: expand((div, mod) => wrap(div - 1, 0, size) * size + mod),
	ArrowRight: expand((div, mod) => div * size + wrap(mod + 1, 0, size)),
	ArrowDown: expand((div, mod) => wrap(div + 1, 0, size) * size + mod),
	ArrowLeft: expand((div, mod) => div * size + wrap(mod - 1, 0, size)),
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

// Stop moving when is margin of grid
const ClampMap: Record<ArrowCodes, (index: number) => number> = {
	ArrowUp: expand((div, mod) => clamp(div - 1, 0, size - 1) * size + mod),
	ArrowRight: expand((div, mod) => div * size + clamp(mod + 1, 0, size - 1)),
	ArrowDown: expand((div, mod) => clamp(div + 1, 0, size - 1) * size + mod),
	ArrowLeft: expand((div, mod) => div * size + clamp(mod - 1, 0, size - 1)),
};

function moveAnt(direction: ArrowCodes) {
	const antIndex = cells.value.findIndex((cell) => cell.type === AntType);

	// Ant is missing on grid
	if (antIndex < 0) return;

	const newIndex = ClampMap[direction](antIndex);
	// Hit the wall
	if (antIndex === newIndex) return;

	const moveIndex = ClampMap[direction](newIndex);
	// Try to move cell only if not wall and next is empty
	if (moveIndex !== newIndex && cells.value[moveIndex].type === EmptyType) {
		cells.value = swapItems(cells.value, newIndex, moveIndex);
	}

	if (cells.value[newIndex].type !== EmptyType) return;
	cells.value = swapItems(cells.value, antIndex, newIndex);
}

function getChar() {
	const text = window.prompt();
	if (!text) return;
	const [firstSymbol] = Array.from(text);
	return firstSymbol.length !== 1 ? firstSymbol : firstSymbol.toUpperCase();
}

function clearBoard() {
	cells.value = createGrid();
}

onMounted(() => {
	const doc = grid.value.ownerDocument;
	function listener(e: KeyboardEvent) {
		if (doc.activeElement.parentElement === grid.value) return;
		if (!includes(arrowCodes, e.code)) return;
		moveAnt(e.code);
	}
	doc.addEventListener("keydown", listener);
	onUnmounted(() => doc.removeEventListener("keydown", listener));
});

onMounted(() => {
	const doc = grid.value.ownerDocument;

	function listener(e: KeyboardEvent) {
		if (doc.activeElement.parentElement !== grid.value) return;
		if (!includes(allCodes, e.code)) return;

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

		const nextIndex = WrapMap[e.code](focusIndex);
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

const swapItems = <T, _>(a: T[], i: number, j: number): T[] => {
	const [first, second] = sort([i, j]);
	return (
		(a[first] &&
			a[second] && [
				...a.slice(0, first),
				a[second],
				...a.slice(first + 1, second),
				a[first],
				...a.slice(second + 1),
			]) ||
		a
	);
};

function sort(arr: number[]): number[] {
	return arr.sort((a, b) => a - b);
}

function getDivMod(n: number) {
	const div = Math.floor(n / size);
	const mod = n % size;
	return { div, mod };
}

function Button(props: any, { slots }) {
	const { class: className, ...rest } = props;
	const classes = [
		"bg-gray-100 active:bg-gray-200 px-4 py-2 uppercase",
		className,
	];
	const newProps = { ...rest, class: classes };
	return h("button", newProps, slots);
}

function includes<T extends U, U>(coll: ReadonlyArray<T>, el: U): el is T {
	return coll.includes(el as T);
}

type ContainerProps = {
	class?: string;
};
const Container: FunctionalComponent<ContainerProps> = (props, { slots }) => {
	const { class: className, ...rest } = props;
	const classes = ["container mx-auto px-4", className];
	return h("div", { ...rest, class: classes }, slots);
};

function expand(cb: (div: number, mod: number) => number) {
	return (index: number) => {
		const { div, mod } = getDivMod(index);
		return cb(div, mod);
	};
}
</script>
