<template>
	<Container class="py-4 max-w-lg">
		<div
			ref="grid"
			class="grid gap-px bg-gray-200 p-px grid-cols-10 grid-rows-10 text-lg sm:text-2xl"
		>
			<button
				v-for="(cell, i) in cells"
				:key="i"
				:class="[
					'flex items-center justify-center aspect-[1/1]',
					'bg-white focus:bg-red-100 outline-none',
					{ 'bg-blue-100': cell.type === AntType },
				]"
				@focus="cellFocus(cell)"
				@click="cellClick(cell)"
			>
				{{ cell.char }}
			</button>
		</div>
		<div class="fixed bottom-0 right-0 md:static m-4">
			<Joystick @click="joystickMove" v-model:record="record" />
		</div>
		<div class="mt-4 mx-auto flex p-px gap-px max-w-max bg-gray-200">
			<textarea
				class="flex-grow p-4 font-mono uppercase resize-none overflow-x-scroll"
				placeholder="Code goes here..."
				v-model="textarea"
			></textarea>
			<div class="grid gap-px place-content-start">
				<Button disabled>Begin</Button>
				<Button disabled>End</Button>
				<Button @click="textarea += 'UP\n'">Up</Button>
				<Button @click="textarea += 'DOWN\n'">Down</Button>
				<Button @click="textarea += 'RIGHT\n'">Right</Button>
				<Button @click="textarea += 'LEFT\n'">Left</Button>
				<Button disabled>While</Button>
				<Button disabled>Do</Button>
				<Button disabled>Repeat</Button>
				<Button disabled>Times</Button>
				<Button disabled>If</Button>
				<Button disabled>Then</Button>
				<Button disabled>Else</Button>
				<Button disabled>Is edge</Button>
				<Button disabled>Is not edge</Button>
				<Button disabled>Procedure</Button>
				<Button disabled>End ...</Button>
			</div>
			<div class="grid gap-px content-start">
				<div class="flex gap-px items-start">
					<div class="grid">
						<Button @click="run">Run</Button>
						<Button @click="setAsAnt">Set as Ant</Button>
						<Button @click="clearBoard">Clear Board</Button>
						<Button @click="setSpeed">
							Set Speed
							<span class="lowercase">({{ speed / 1000 }}s)</span>
						</Button>
					</div>
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
	every,
	getAntCell,
	getCharCell,
	getEmptyCell,
	includes,
	sleep,
	swapItems,
} from "~~/utils";
import textareaInit from "~~/utils/textarea-init";

const speed = ref(50);
const textarea = ref(textareaInit);
const record = ref(false);
const letters = { 52: "A", 53: "N", 54: "T" };
const focusedCell = ref<Cell>();
const grid = ref<HTMLElement>();
const size = 10;
const cells = ref(createGrid({ antIndex: 11, letters, size }));
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

const MoveMap: Record<ArrowCodes, string> = {
	ArrowUp: "UP",
	ArrowDown: "DOWN",
	ArrowLeft: "LEFT",
	ArrowRight: "RIGHT",
};

function joystickMove(direction: ArrowCodes) {
	if (record.value) textarea.value += `${MoveMap[direction]}\n`;
	moveAnt(direction);
}

function cellFocus(cell: Cell) {
	focusedCell.value = cell;
}

function cellClick(cell: Cell) {
	const newCell = getCharCell(getChar());
	cells.value = cells.value.map((c) => (c !== cell ? c : newCell));
}

function moveAnt(direction: ArrowCodes): boolean {
	const antIndex = cells.value.findIndex((cell) => cell.type === AntType);

	// Ant is missing on grid
	if (antIndex < 0) return false;

	const newIndex = clampGrid(direction, antIndex);
	// Hit the wall
	if (antIndex === newIndex) return false;

	const moveIndex = clampGrid(direction, newIndex);
	// Try to move cell only if not wall and next is empty
	if (moveIndex !== newIndex && cells.value[moveIndex].type === EmptyType) {
		cells.value = swapItems(cells.value, newIndex, moveIndex);
	}

	if (cells.value[newIndex].type !== EmptyType) return false;
	cells.value = swapItems(cells.value, antIndex, newIndex);
	return true;
}

function getChar() {
	const text = window.prompt();
	if (!text) return;
	const [firstSymbol] = Array.from(text);
	return firstSymbol.length !== 1 ? firstSymbol : firstSymbol.toUpperCase();
}

function setSpeed() {
	const text = window.prompt("Number of seconds");
	try {
		speed.value = Number.parseFloat(text) * 1000;
	} catch {}
}

function clearBoard() {
	cells.value = createGrid({ size });
}

async function run() {
	const tokens = textarea.value
		.toUpperCase()
		.split("\n")
		.map((t) => t.trim())
		.filter(Boolean);

	const MoveMap: Record<string, ArrowCodes> = {
		UP: "ArrowUp",
		DOWN: "ArrowDown",
		LEFT: "ArrowLeft",
		RIGHT: "ArrowRight",
	};

	const passed = await every(tokens, async (token) =>
		sleep(speed.value).then(() => moveAnt(MoveMap[token]))
	);

	setTimeout(() =>
		passed ? window.alert("SUCCESS") : window.alert("FAILED")
	);
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
