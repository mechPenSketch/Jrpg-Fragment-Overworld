tool
extends PlayingPiece

var grid

signal turning
var is_moving = false
var tween
var target_pos = Vector2()
var blocks = []
var is_blocked:bool = false
export (Dictionary) var raycast_directions
var raycast
export (Resource) var incoming
signal incoming_gone

func _ready():
	if !Engine.editor_hint:
		grid = get_parent()
	
		tween = $Tween
		
		turn(Vector2(0,1))

func _direction(dir:Vector2):
	if !is_moving:
		
		turn(dir)
		if !raycast.is_colliding():
			grid_x += dir.x
			grid_y += dir.y
			target_pos = get_position() + dir * Vector2(cell_width, cell_height)
			
			# ADD INCOMING BLOCK
			var new_incoming = incoming.instance()
			new_incoming.set_position(target_pos)
			grid.add_child(new_incoming)
			connect("incoming_gone", new_incoming, "queue_free")
			
			tween.move_char(self, target_pos)
			is_moving = true

func _on_tween_completed(_o, _k):
	is_moving = false
	emit_signal("incoming_gone")

func _on_area_entered(a):
	if a.get_parent() != $Position2D:
		blocks.append(a)
		is_blocked = true

func _on_area_exited(a):
	blocks.erase(a)
	is_blocked = blocks.size()

func turn(dir:Vector2):
	raycast = get_node(raycast_directions[dir])
	emit_signal("turning", dir)