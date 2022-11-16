extends Node

@onready var main = get_parent();
@onready var upgrades_vbox = $"../MainHBox/RightVBox/RightLowerPanel/RightLowerVBox/UpgradesScrollContainer/UpgradesVBox";
@onready var upgrade_hbox = preload("res://upgrade_hbox.tscn");

@onready var upgrades = {
	"Colony Expansion 1" : {
		"description" : "Expand from a small to medium sized anthill.",
		"unlocked" : 1,
		"listed" : 0,
		"owned" : 0,
		"cost" : 100,
		"listing" : upgrade_hbox.instantiate(),
	},
	"Potent Pheromones" : {
		"description" : "Pheromone trails become stronger, Worker Ants gather food twice as fast.",
		"unlocked" : 1,
		"listed" : 0,
		"owned" : 0,
		"cost" : 100,
		"listing" : upgrade_hbox.instantiate(),
	},
};

func _ready():
	update_list();


func update_list():
	for u in upgrades:
		if (upgrades[u]["unlocked"] == 1): # Upgrade is unlocked
			if (upgrades[u]["listed"] == 0): # Upgrade is not listed
				if (upgrades[u]["owned"] == 0):
					upgrades[u]["listing"].get_node("NameLabel").text = "%s [cost: %d]" % [u, upgrades[u]["cost"]];
					upgrades[u]["listing"].get_node("BuyButton").pressed.connect(do_buy.bind(u));
					upgrades[u]["listed"] = 1;
					upgrades_vbox.add_child(upgrades[u]["listing"]);
			elif (upgrades[u]["owned"] == 1):
				upgrades[u]["listing"].queue_free();
				upgrades[u]["listed"] = 0;

func do_buy(upgrade):
	upgrades[upgrade]["owned"] = 1;
	update_list();

	main.console_handler.add_message("Upgrade Purchased: '%s'" % upgrade);
