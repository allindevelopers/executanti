export const EmptyType = Symbol.for("empty");
export const CharType = Symbol.for("char");
export const AntType = Symbol.for("ant");
type AnyType = typeof EmptyType | typeof CharType | typeof AntType;

export type Cell = { type: AnyType; char?: string };
export const getEmptyCell = (): Cell => ({ type: EmptyType, char: undefined });
export const getCharCell = (char: string): Cell => ({ type: CharType, char });
export const getAntCell = (char: string): Cell => ({ type: AntType, char });

type CreateGridProps = {
	antIndex?: number;
	size?: number;
	letters?: Record<number, string>;
};
export function createGrid(props: CreateGridProps = {}) {
	const { antIndex, size = 10, letters = {} } = props;
	return Array.from({ length: size * size }, (_, index) => {
		if (antIndex === index) return getAntCell("🐜");
		if (letters[index]) return getCharCell(letters[index]);
		return getEmptyCell();
	});
}

export function wrap(num: number, min: number, max: number): number {
	const rangeSize = max - min;
	return ((((num - min) % rangeSize) + rangeSize) % rangeSize) + min;
}

export function clamp(val: number, min: number = 0, max: number = 1): number {
	return Math.max(min, Math.min(max, val));
}

export function swapItems<T, _>(a: T[], i: number, j: number): T[] {
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
}

export function sort(arr: number[]): number[] {
	return arr.sort((a, b) => a - b);
}

export function getDivMod(n: number, size: number) {
	const div = Math.floor(n / size);
	const mod = n % size;
	return { div, mod };
}

export function includes<T extends U, U>(
	coll: ReadonlyArray<T>,
	el: U
): el is T {
	return coll.includes(el as T);
}

export type ArrowCodes = typeof arrowCodes[number];
export const arrowCodes = [
	"ArrowUp",
	"ArrowRight",
	"ArrowDown",
	"ArrowLeft",
] as const;

// Move to other side of the grid when margin
export function createWrapGrid(size: number) {
	const WrapGrid: Record<ArrowCodes, (index: number) => number> = {
		ArrowUp: expand(
			size,
			(div, mod) => wrap(div - 1, 0, size) * size + mod
		),
		ArrowRight: expand(
			size,
			(div, mod) => div * size + wrap(mod + 1, 0, size)
		),
		ArrowDown: expand(
			size,
			(div, mod) => wrap(div + 1, 0, size) * size + mod
		),
		ArrowLeft: expand(
			size,
			(div, mod) => div * size + wrap(mod - 1, 0, size)
		),
	};

	return (direction: ArrowCodes, index: number) => WrapGrid[direction](index);
}

// Stop moving when is margin of grid
export function createClampGrid(size: number) {
	const ClampGrid: Record<ArrowCodes, (index: number) => number> = {
		ArrowUp: expand(
			size,
			(div, mod) => clamp(div - 1, 0, size - 1) * size + mod
		),
		ArrowRight: expand(
			size,
			(div, mod) => div * size + clamp(mod + 1, 0, size - 1)
		),
		ArrowDown: expand(
			size,
			(div, mod) => clamp(div + 1, 0, size - 1) * size + mod
		),
		ArrowLeft: expand(
			size,
			(div, mod) => div * size + clamp(mod - 1, 0, size - 1)
		),
	};

	return (direction: ArrowCodes, index: number) =>
		ClampGrid[direction](index);
}

function expand(size: number, cb: (div: number, mod: number) => number) {
	return (index: number) => {
		const { div, mod } = getDivMod(index, size);
		return cb(div, mod);
	};
}

export const sleep = (ms: number) =>
	new Promise((resolve) => setTimeout(resolve, ms));

export async function every<T>(
	array: T[],
	predicate: (value: T, index: number, array: T[]) => Promise<boolean>,
	thisArg?: any
): Promise<boolean> {
	for (let i = 0; i < array.length; i++) {
		const passed = await predicate.call(thisArg, array[i], i, array);
		if (!passed) return false;
	}

	return true;
}
