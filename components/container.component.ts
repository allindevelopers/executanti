import { FunctionalComponent } from "@vue/runtime-dom";

type ContainerProps = { class?: string };
const Container: FunctionalComponent<ContainerProps> = (props, { slots }) => {
	const { class: className, ...rest } = props;
	const classes = ["container mx-auto px-4", className];
	return h("div", { ...rest, class: classes }, slots);
};

export default Container;
