<template>
	<Container class="py-4 max-w-lg">
		<div
			ref="grid"
			class="grid gap-px bg-gray-200 grid-cols-10 grid-rows-10 text-lg sm:text-2xl rounded-xl border overflow-hidden"
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
			>
				{{ cell.char }}
			</button>
		</div>
		<div
			class="grid gap-px grid-cols-7 sm:grid-cols-10 my-4 border border-transparent"
		>
			<Control @click="run" class="rounded-l-xl" title="Run">
				<PlayIcon class="h-6 w-6" />
			</Control>
			<Control @click="cellEdit" title="Edit focused cell">
				<EditIcon class="h-6 w-6" />
			</Control>
			<Control
				@click="setSpeed"
				:title="`Set speed (${speed / 1000} seconds)`"
				class="relative"
			>
				<BoltIcon class="h-6 w-6" />
				<span
					class="absolute lowercase text-gray-400 text-xs right-1 bottom-px"
				>
					{{ speed / 1000 }}s
				</span>
			</Control>
			<Control @click="setAsAnt" title="Set current cell as Ant">
				🐜
			</Control>
			<Control @click="clearBoard" title="Clear board">
				<TrashIcon class="h-6 w-6" />
			</Control>
			<Control @click="helpClick" class="rounded-r-xl">
				<QuestionIcon class="h-6 w-6" />
			</Control>
		</div>
		<div class="fixed bottom-0 right-0 m-4">
			<Joystick @click="joystickMove" v-model:record="record" />
		</div>
		<div class="my-4 flex gap-px bg-gray-200 rounded-xl">
			<textarea
				class="flex-grow p-4 font-mono uppercase resize-none rounded-l-xl border-r-1"
				placeholder="Code goes here..."
				v-model="textarea"
			></textarea>
			<div class="grid gap-px border-r border-t border-b rounded-xl">
				<Button disabled class="rounded-tr-xl">Begin</Button>
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
				<Button disabled class="rounded-br-xl">End ...</Button>
			</div>
		</div>
	</Container>
</template>

<script setup lang="ts">
import Container from "~~/components/container.component";
import Joystick from "~~/components/joystick.component.vue";
import Button from "~~/components/button.component";
import PlayIcon from "~~/components/play.component.vue";
import TrashIcon from "~~/components/trash.component.vue";
import BoltIcon from "~~/components/bolt.component.vue";
import EditIcon from "~~/components/edit.component.vue";
import QuestionIcon from "~~/components/question.component.vue";
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

function cellFocus(cell?: Cell) {
	focusedCell.value = cell;
}

function cellEdit() {
	if (!focusedCell.value) return;
	const newCell = getCharCell(getChar());
	cells.value = cells.value.map((c) =>
		c !== focusedCell.value ? c : newCell
	);
}

function helpClick() {
	window.alert("Guide coming soon!");
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
	const text = window.prompt("Enter a character for cell. Can be emoji");
	if (!text) return;
	const [firstSymbol] = Array.from(text);
	return firstSymbol.length !== 1 ? firstSymbol : firstSymbol.toUpperCase();
}

function setSpeed() {
	const text = window.prompt("Number of seconds for Ant to run");
	try {
		speed.value = Number.parseFloat(text) * 1000;
	} catch {}
}

function clearBoard() {
	cells.value = createGrid({
		size,
		antIndex: Math.floor(Math.random() * size * size),
	});
	textarea.value = "";
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

function Control(props: any, { slots }) {
	const { class: className, ...rest } = props;
	const classes = [
		"rounded",
		"shadow focus:shadow-lg active:shadow-lg hover:shadow-lg",
		"flex items-center justify-center aspect-[1/1]",
		"bg-white text-yellow-400",
		"outline-none focus:ring-1 ring-yellow-400",
		className,
	];
	const newProps = { ...rest, class: classes };
	return h("button", newProps, slots);
}
</script>
