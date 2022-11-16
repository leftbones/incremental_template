extends MarginContainer

# Handlers
@onready var console_handler = $ConsoleHandler;
@onready var store_handler = $StoreHandler;
@onready var upgrades_handler = $UpgradesHandler;
@onready var milestones_handler = $MilestonesHandler;
@onready var cheats = $CheatsHandler;

var show_precise_values = true;

# Preloads/References
@onready var egg_progress_bar = $MainHBox/LeftVBox/LeftUpperPanel/LeftUpperVBox/EggProgressBar;
@onready var colony_info_box = $MainHBox/LeftVBox/LeftUpperPanel/LeftUpperVBox/ColonyScrollContainer/ColonyVBox;
@onready var colony_info_item = preload("res://info_hbox.tscn");
@onready var plus_minus_button = preload("res://button_hbox.tscn");

# Colony
var total_ants := 0.0;
var queen_ants := 0.0;
var worker_ants := 0.0;

var max_total_ants := 0.0;
var max_queen_ants := 0.0;
var max_worker_ants := 0.0;

var queen_power := 0.0;
var worker_power := 0.0;

var total_food := 0.0;
var max_total_food := 999.0; #10.0;

var total_eggs := 0.0;
var max_total_eggs := 999.0; #3.0;
var egg_cost := 1; # food cost per second to make 1 egg

# Multipliers (These are applied at the end of calculations)
var global_multiplier := 1.0; 	# Applied to all calculations
var queen_multiplier := 1.0; 	# Applied to Queen Ant power (eggs per second)
var food_multiplier := 1.0; 	# Applied to Worker Ant power (food per second)
var cost_multiplier := 1.0;	 	# Applied to Queen Ant cost (food per second)

# Interface
@onready var total_ants_tracker = colony_info_item.instantiate();
@onready var total_eggs_tracker = colony_info_item.instantiate();
@onready var total_food_tracker = colony_info_item.instantiate();
@onready var queen_ants_tracker = colony_info_item.instantiate();
@onready var worker_ants_tracker = colony_info_item.instantiate();

@onready var empty_space_1 = colony_info_item.instantiate();
@onready var empty_space_2 = colony_info_item.instantiate();

@onready var eggs_per_second_tracker = colony_info_item.instantiate();
@onready var food_per_second_tracker = colony_info_item.instantiate();

# Timers
@onready var queen_timer = Timer.new();


func _ready():
	# Load Save
	console_handler.add_message("Thanks for playing Ant Simulator Alpha!");
	console_handler.add_message("For suggestions/bug reports, open a GitHub issue!");

	# Timers
	add_child(queen_timer);
	queen_timer.timeout.connect(do_queen_timer);
	queen_timer.start(1);

	# Colony Info
	colony_info_box.add_child(total_ants_tracker);
	colony_info_box.add_child(total_eggs_tracker);
	colony_info_box.add_child(total_food_tracker);
	colony_info_box.add_child(empty_space_1);
	colony_info_box.add_child(queen_ants_tracker);
	colony_info_box.add_child(worker_ants_tracker);
	colony_info_box.add_child(empty_space_2);
	colony_info_box.add_child(eggs_per_second_tracker);
	colony_info_box.add_child(food_per_second_tracker);

	# Trackers
	total_ants_tracker.get_node("NameLabel").text = "Total Ants";
	total_eggs_tracker.get_node("NameLabel").text = "Eggs";
	total_food_tracker.get_node("NameLabel").text = "Food";
	queen_ants_tracker.get_node("NameLabel").text = "Queen Ants";
	worker_ants_tracker.get_node("NameLabel").text = "Worker Ants";

	eggs_per_second_tracker.get_node("NameLabel").text = "Eggs Per Second";
	food_per_second_tracker.get_node("NameLabel").text = "Food Per Second";


func _process(delta):
	do_increment(delta);

	# Update Info
	total_ants = 0;
	max_total_ants = 0;

	queen_ants = store_handler.items["Queen Ant"]["owned"];
	max_queen_ants = store_handler.items["Queen Ant"]["max owned"];
	queen_power = store_handler.items["Queen Ant"]["base power"];

	worker_ants = store_handler.items["Worker Ant"]["owned"];
	max_worker_ants = store_handler.items["Worker Ant"]["max owned"];
	worker_power = store_handler.items["Worker Ant"]["base power"];

	for i in store_handler.items:
		total_ants += store_handler.items[i]["owned"];
		max_total_ants += store_handler.items[i]["max owned"];

	# Info Trackers
	total_ants_tracker.get_node("InfoLabel").text = "%d / %d" % [total_ants, max_total_ants];
	total_eggs_tracker.get_node("InfoLabel").text = "%d / %d" % [total_eggs, max_total_eggs];
	total_food_tracker.get_node("InfoLabel").text = "%d / %d" % [total_food, max_total_food];

	queen_ants_tracker.get_node("InfoLabel").text = "%d / %d" % [queen_ants, max_queen_ants];
	worker_ants_tracker.get_node("InfoLabel").text = "%d / %d" % [worker_ants, max_worker_ants];

	eggs_per_second_tracker.get_node("InfoLabel").text = "%.2f" % calc_eggs_per_sec();
	food_per_second_tracker.get_node("InfoLabel").text = "%.2f" % calc_food_per_sec();

	queen_ants_tracker.tooltip_text = "-%.2f food per second" % calc_cost_per_sec();
	worker_ants_tracker.tooltip_text = "+%.2f food per second" % calc_food_per_sec();

	egg_progress_bar.value = ((total_eggs - floor(total_eggs)) / 1.0) * 100;

	if (show_precise_values): # move to config handler
		total_eggs_tracker.get_node("InfoLabel").text += " (%.2f)" % total_eggs;
		total_food_tracker.get_node("InfoLabel").text += " (%.2f)" % total_food;

		queen_ants_tracker.get_node("InfoLabel").text += " (-%.2f food/s)" % calc_cost_per_sec()
		worker_ants_tracker.get_node("InfoLabel").text += " (+%.2f food/s)" % calc_food_per_sec();

		eggs_per_second_tracker.get_node("InfoLabel").text += " (%.2f)" % calc_eggs_per_sec();
		food_per_second_tracker.get_node("InfoLabel").text += " (%.2f)" % calc_food_per_sec();


func do_increment(delta):
	if (total_food < max_total_food):
		total_food += calc_food_per_sec() * delta;

	if (total_eggs < max_total_eggs):
		do_make_egg();

	# if (total_eggs < max_total_eggs && total_food > calc_cost_per_sec()):
	# 	total_eggs += calc_eggs_per_sec() * delta;
	# 	total_food -= calc_cost_per_sec() * delta;


func do_make_egg():
	if (total_food >= calc_cost_per_sec() * queen_ants):
		total_eggs += calc_eggs_per_sec();
		total_food -= calc_cost_per_sec();

func do_queen_timer():
	pass
	# if (total_eggs < max_total_eggs && total_food > egg_cost):
	# 	total_eggs += calc_eggs_per_sec();
	# 	total_food -= calc_cost_per_sec();


func calc_eggs_per_sec():
	return queen_ants * queen_power * queen_multiplier * global_multiplier;


func calc_food_per_sec():
	return worker_ants * worker_power * food_multiplier * global_multiplier;


func calc_cost_per_sec():
	return queen_ants * egg_cost * cost_multiplier * global_multiplier;
