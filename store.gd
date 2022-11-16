extends Node

@onready var main = get_parent();
@onready var store_vbox = $"../MainHBox/RightVBox/RightUpperPanel/RightUpperVBox/StoreScrollContainer/StoreVBox";
@onready var item_hbox = preload("res://item_hbox.tscn");

@onready var items = {
	"Queen Ant" : {
		"description" : "Lays eggs at a base rate of 0.025 eggs per second.",
		"unlocked" : 1,
		"owned" : 1,
		"max owned" : 1, 
		"cost" : 100,
		"base cost" : 100,
		"base power" : 0.01,
		"cost modifier" : 1.0,
		"power modifier" : 1.0,
		"listing" : item_hbox.instantiate(),
	},
	"Worker Ant" : {
		"description" : "Gathers food at a base rate of 0.1 food per second.",
		"unlocked" : 1,
		"owned" : 0,
		"max owned" : 2,
		"cost" : 1,
		"base cost" : 1,
		"base power" : 0.1,
		"cost modifier" : 1.0,
		"power modifier" : 1.0,
		"listing" : item_hbox.instantiate(),
	},
};


func _ready():
	for i in items:
		items[i]["listing"].get_node("NameLabel").text = "%s [cost: %d]" % [i, items[i]["cost"]];
		items[i]["listing"].get_node("BuyButton1").pressed.connect(do_buy.bind(1, i));
		items[i]["listing"].get_node("BuyButton10").pressed.connect(do_buy.bind(10, i));
		items[i]["listing"].get_node("BuyButton100").pressed.connect(do_buy.bind(100, i));
		store_vbox.add_child(items[i]["listing"]);


func do_buy(amount, item):
	items[item]["owned"] += amount;
	main.console_handler.add_message("Purchased %dx %s(s)." % [amount, item])
