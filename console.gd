extends Node

@onready var main = get_parent();
@onready var output_label = preload("res://output_label.tscn");

@onready var console = $"../MainHBox/LeftVBox/LeftLowerPanel/ConsoleScrollContainer/ConsoleVBox";
@onready var scrollbox = $"../MainHBox/LeftVBox/LeftLowerPanel/ConsoleScrollContainer";
@onready var scrollbar = scrollbox.get_v_scroll_bar();


func add_message(message):
	var msg_label = output_label.instantiate();
	msg_label.text = "• " + message;
	console.add_child(msg_label);
	scrollbox.scroll_vertical = scrollbar.max_value;

	if (console.get_child_count() > 6):
		console.get_child(0).queue_free();
