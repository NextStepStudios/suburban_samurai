extends Node
func _process(delta):
	# connected controllers
	var pads = Input.get_connected_joypads()
	if pads.empty():
		print("No controller detected")
	else:
		print("Connected pads:", pads)

func _input(event):
	if event is InputEventJoypadButton:
		print("JOY EVENT → device:", event.device, "button_index:", event.button_index, "pressed:", event.pressed)
	if event is InputEventKey:
		print("KEY EVENT → scancode:", event.get_keycode(), "pressed:", event.pressed)
