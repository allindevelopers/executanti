<template>
	<div
		class="inline-grid grid-cols-[repeat(3,50px)] grid-rows-[repeat(3,50px)]"
		v-bind="$attrs"
	>
		<div></div>
		<Button @click="$emit('click', 'ArrowUp')" title="Up">
			<UpIcon class="h-8 w-8" />
		</Button>
		<div></div>
		<Button @click="$emit('click', 'ArrowLeft')" title="Left">
			<LeftIcon class="h-8 w-8" />
		</Button>
		<Button
			class="self-center justify-self-center rounded-full"
			color="text-red-500"
			:title="
				record ? 'Stop Record Joystick moves' : 'Record Joystick moves'
			"
			@click="$emit('update:record', !record)"
		>
			<StopIcon v-if="record" class="h-8 w-8" />
			<RecordIcon v-else class="h-8 w-8" />
		</Button>

		<Button @click="$emit('click', 'ArrowRight')" title="Right">
			<RightIcon class="h-8 w-8" />
		</Button>
		<div></div>
		<Button @click="$emit('click', 'ArrowDown')" title="Down">
			<DownIcon class="h-8 w-8" />
		</Button>
		<div></div>
	</div>
</template>

<script lang="ts">
import { defineComponent, PropType } from "vue";
import LeftIcon from "./left.component.vue";
import UpIcon from "./up.component.vue";
import RightIcon from "./right.component.vue";
import DownIcon from "./down.component.vue";
import RecordIcon from "./record.component.vue";
import StopIcon from "./stop.component.vue";

export default defineComponent({
	props: {
		record: Boolean as PropType<boolean>,
	},
	inheritAttrs: false,
	components: {
		Button,
		LeftIcon,
		UpIcon,
		RightIcon,
		DownIcon,
		RecordIcon,
		StopIcon,
	},
	emits: ["click", "update:record"],
});

function Button(props: any, { slots }) {
	const { class: className, color = "text-yellow-400", ...rest } = props;
	const classes = [
		"bg-white focus:outline-none focus:ring-1 ring-yellow-400 rounded-xl hover:bg-gray-50 shadow-md active:shadow flex items-center justify-center select-none",
		color,
		className,
	];
	const newProps = { ...rest, class: classes };
	return h("button", newProps, slots);
}
</script>
