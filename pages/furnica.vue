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
			<div class="grid gap-px content-start">
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
				<div class="flex gap-px items-start">
					<Button @click="setAsAnt">Set as Ant</Button>
					<Button @click="clearBoard">Clear Board</Button>
					<Joystick class="ml-auto mr-4 mt-4" @click="moveAnt" />
				</div>
			</div>
		</div>
	</Container>
</template>

<script setup lang="ts">
import Container from "~~/components/container.component";
import Joystick from "~~/components/joystick.component.vue";
import Button from "~~/components/button.component";
import {
	AntType,
	ArrowCodes,
	arrowCodes,
	Cell,
	createClampGrid,
	createGrid,
	createWrapGrid,
	EmptyType,
	getAntCell,
	getCharCell,
	getEmptyCell,
	includes,
	swapItems,
} from "~~/utils";

const letters = { 52: "A", 53: "N", 54: "T" };
const focusedCell = ref<Cell>();
const grid = ref<HTMLElement>();
const cells = ref(createGrid({ antIndex: 11, letters }));
const size = 10;
const controllCodes = ["Backspace", "Enter", "Escape"] as const;
const allCodes = [...arrowCodes, ...controllCodes];

const wrapGrid = createWrapGrid(size);
const clampGrid = createClampGrid(size);

function setAsAnt() {
	const cellIndex = cells.value.indexOf(focusedCell.value);
	if (cellIndex < 0) return;

	const remove = (cell: Cell) =>
		cell.type !== AntType ? cell : getCharCell(cell.char);
	const set = (cell: Cell, index: number) =>
		index === cellIndex ? getAntCell(cell.char) : cell;

	cells.value = cells.value.map(remove).map(set);
}

function moveAnt(direction: ArrowCodes) {
	const antIndex = cells.value.findIndex((cell) => cell.type === AntType);

	// Ant is missing on grid
	if (antIndex < 0) return;

	const newIndex = clampGrid(direction, antIndex);
	// Hit the wall
	if (antIndex === newIndex) return;

	const moveIndex = clampGrid(direction, newIndex);
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

		const nextIndex = wrapGrid(e.code, focusIndex);
		const selector = `:scope button:nth-child(${nextIndex + 1})`;
		const button = grid.value.querySelector<HTMLElement>(selector);
		button.focus();
	}

	doc.addEventListener("keydown", listener);
	onUnmounted(() => doc.removeEventListener("keydown", listener));
});
</script>
