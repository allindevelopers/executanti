import { FunctionalComponent } from "@vue/runtime-dom";

const Button: FunctionalComponent<any> = (props, { slots }) => {
	const { class: className, ...rest } = props;
	const classes = [
		"bg-white active:bg-gray-200 px-4 py-2 uppercase disabled:text-gray-300 hover:bg-gray-100",
		className,
	];
	const newProps = { ...rest, class: classes };
	return h("button", newProps, slots);
};

export default Button;
