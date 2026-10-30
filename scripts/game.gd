extends Node3D

const Assets = preload("res://scripts/procedural_assets.gd")
const GroundShader = preload("res://shaders/arena_ground.gdshader")

const HERO_SPEED := 9.0
const ATTACK_RANGE := 8.5
const ATTACK_DAMAGE := 38.0
const SKILL_DAMAGE := 92.0

var hero: CharacterBody3D
var hero_visual: Node3D
var camera: Camera3D
var hud: Label
var status_label: Label
var enemies: Array[Node3D] = []
var allies: Array[Node3D] = []
var neutral_monsters: Array[Node3D] = []
var active_fx: Array[Node3D] = []
var blue_core_hp := 1200.0
var red_core_hp := 1200.0
var attack_cooldown := 0.0
var skill_cooldown := 0.0
var attack_anim_timer := 0.0
var status_timer := 0.0
var game_time := 0.0
var game_over := false

func _ready() -> void:
	_build_arena()
	_spawn_hero()
	_spawn_waves()
	_spawn_jungle_camps()
	_build_hud()
	_update_hud()

func _process(delta: float) -> void:
	game_time += delta
	attack_cooldown = maxf(0.0, attack_cooldown - delta)
	skill_cooldown = maxf(0.0, skill_cooldown - delta)
	attack_anim_timer = maxf(0.0, attack_anim_timer - delta)
	status_timer = maxf(0.0, status_timer - delta)
	if not game_over:
		_update_minions(delta)
		_update_neutral_monsters(delta)
	_update_camera(delta)
	if hero_visual:
		var moving := hero != null and Vector2(hero.velocity.x, hero.velocity.z).length() > 0.4
		Assets.animate_hero(hero_visual, game_time, moving, attack_anim_timer > 0.0)
	_update_fx(delta)
	_update_hud()

func _physics_process(delta: float) -> void:
	if hero == null or game_over:
		return
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var forward := -camera.global_basis.z
	var right := camera.global_basis.x
	forward.y = 0.0
	right.y = 0.0
	var direction := (right.normalized() * input_dir.x + forward.normalized() * input_dir.y).normalized()
	hero.velocity.x = direction.x * HERO_SPEED
	hero.velocity.z = direction.z * HERO_SPEED
	if not hero.is_on_floor():
		hero.velocity.y -= 24.0 * delta
	else:
		hero.velocity.y = -0.5
	hero.move_and_slide()
	if direction.length() > 0.1:
		hero.look_at(hero.global_position + direction, Vector3.UP)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("attack") and not game_over:
		_basic_attack()
	if event.is_action_pressed("skill") and not game_over:
		_cast_skill()
	if event.is_action_pressed("restart") and game_over:
		get_tree().reload_current_scene()

func _build_arena() -> void:
	_add_box("Grass Field", Vector3(0, -0.7, 0), Vector3(104, 1.4, 76), Color.WHITE, true, true)
	for z in [-23.0, 0.0, 23.0]:
		_add_box("Stone Lane", Vector3(0, 0.10, z), Vector3(88, 0.2, 7.5), Color(0.34, 0.38, 0.42), true)
		_add_box("Lane Edge North", Vector3(0, 0.18, z + 3.9), Vector3(88, 0.12, 0.22), Color(0.19, 0.24, 0.25), false)
		_add_box("Lane Edge South", Vector3(0, 0.18, z - 3.9), Vector3(88, 0.12, 0.22), Color(0.19, 0.24, 0.25), false)
		for x in range(-38, 39, 8):
			_add_box("Lane Inlay", Vector3(float(x), 0.22, z), Vector3(0.42, 0.035, 0.28), Color(0.75, 0.69, 0.48), false)
	_add_box("Blue Base Platform", Vector3(-44, 0.28, 0), Vector3(13, 0.55, 34), Color(0.07, 0.18, 0.48), true)
	_add_box("Red Base Platform", Vector3(44, 0.28, 0), Vector3(13, 0.55, 34), Color(0.48, 0.08, 0.08), true)
	_make_tower("Blue Core", Vector3(-46, 0.65, 0), Color(0.1, 0.55, 1.0))
	_make_tower("Red Core", Vector3(46, 0.65, 0), Color(1.0, 0.2, 0.12))
	for z in [-23.0, 0.0, 23.0]:
		_make_tower("Blue Tower", Vector3(-26, 0.65, z), Color(0.12, 0.55, 1.0))
		_make_tower("Red Tower", Vector3(26, 0.65, z), Color(1.0, 0.22, 0.12))
	for x in [-19.0, -7.0, 7.0, 19.0]:
		for z in [-13.0, 13.0]:
			_make_tree(Vector3(x, 0, z))
	for x in [-33.0, -12.0, 12.0, 33.0]:
		_make_bush(Vector3(x, 0, -9.5))
		_make_bush(Vector3(x + 2.0, 0, 9.5))

	var light := DirectionalLight3D.new()
	light.name = "WarmSun"
	light.rotation_degrees = Vector3(-48, -32, 0)
	light.light_energy = 1.4
	light.shadow_enabled = true
	add_child(light)

	var world := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_SKY
	var sky := Sky.new()
	var sky_material := ProceduralSkyMaterial.new()
	sky_material.sky_top_color = Color(0.12, 0.22, 0.36)
	sky_material.sky_horizon_color = Color(0.72, 0.79, 0.82)
	sky_material.ground_bottom_color = Color(0.08, 0.12, 0.1)
	sky_material.ground_horizon_color = Color(0.34, 0.42, 0.32)
	sky.sky_material = sky_material
	env.sky = sky
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.48, 0.57, 0.64)
	env.ambient_light_energy = 0.72
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	env.fog_enabled = true
	env.fog_light_color = Color(0.43, 0.55, 0.54)
	env.fog_density = 0.0018
	world.environment = env
	add_child(world)

func _spawn_hero() -> void:
	hero = CharacterBody3D.new()
	hero.name = "PlayerWindRonin"
	hero.position = Vector3(-34, 1.0, 0)
	var shape := CapsuleShape3D.new()
	shape.radius = 0.55
	shape.height = 2.0
	var collision := CollisionShape3D.new()
	collision.shape = shape
	hero.add_child(collision)
	hero_visual = Assets.make_hero()
	hero_visual.position.y = -0.9
	hero.add_child(hero_visual)
	add_child(hero)

	camera = Camera3D.new()
	camera.name = "FollowCamera"
	camera.current = true
	camera.fov = 52.0
	camera.position = hero.position + Vector3(0, 23, 20)
	add_child(camera)
	camera.look_at(hero.position, Vector3.UP)

func _spawn_waves() -> void:
	for lane_z in [-23.0, 0.0, 23.0]:
		for i in range(4):
			_make_minion(Vector3(-32.0 - i * 1.8, 0.24, lane_z + (i % 2) * 1.0), true)
			_make_minion(Vector3(32.0 + i * 1.8, 0.24, lane_z - (i % 2) * 1.0), false)

func _make_minion(pos: Vector3, blue: bool) -> void:
	var unit := Node3D.new()
	unit.name = "Blue Minion" if blue else "Red Minion"
	unit.position = pos
	unit.set_meta("blue", blue)
	unit.set_meta("hp", 120.0)
	unit.set_meta("attack_timer", randf_range(0.1, 0.8))
	var visual := Assets.make_minion(blue)
	unit.add_child(visual)
	add_child(unit)
	if blue:
		allies.append(unit)
	else:
		enemies.append(unit)

func _spawn_jungle_camps() -> void:
	_make_golem_camp(Vector3(-13, 0.0, 10.5), "Blue-side jungle")
	_make_golem_camp(Vector3(13, 0.0, -10.5), "Red-side jungle")

func _make_golem_camp(pos: Vector3, camp_name: String) -> void:
	for i in range(2):
		var monster := Assets.make_golem()
		monster.name = "Ancient Moss Golem"
		monster.position = pos + Vector3(float(i) * 2.0 - 1.0, 0.0, float(i) * 0.65)
		monster.scale = Vector3.ONE * (1.15 if i == 0 else 0.82)
		monster.set_meta("hp", 360.0 if i == 0 else 210.0)
		monster.set_meta("max_hp", 360.0 if i == 0 else 210.0)
		monster.set_meta("camp", camp_name)
		monster.set_meta("phase", randf() * TAU)
		neutral_monsters.append(monster)
		add_child(monster)
	_make_camp_marker(pos)

func _make_camp_marker(pos: Vector3) -> void:
	var marker := MeshInstance3D.new()
	var disc := CylinderMesh.new()
	disc.top_radius = 2.5
	disc.bottom_radius = 2.5
	disc.height = 0.06
	marker.mesh = disc
	marker.position = pos + Vector3(0, 0.05, 0)
	marker.material_override = _mat(Color(0.12, 0.28, 0.19))
	add_child(marker)

func _update_minions(delta: float) -> void:
	_update_team_minions(allies, enemies, 1.0, delta, true)
	_update_team_minions(enemies, allies, -1.0, delta, false)
	if red_core_hp <= 0.0 or blue_core_hp <= 0.0:
		game_over = true
		_show_message("GAME OVER  |  Press R to restart", 999.0)

func _update_team_minions(units: Array[Node3D], opponents: Array[Node3D], direction: float, delta: float, blue_attacking: bool) -> void:
	for unit in units.duplicate():
		if not is_instance_valid(unit):
			units.erase(unit)
			continue
		var hp := float(unit.get_meta("hp"))
		if hp <= 0.0:
			units.erase(unit)
			unit.queue_free()
			continue
		var target := _nearest_unit(unit, opponents, 2.1)
		if target != null:
			var timer := float(unit.get_meta("attack_timer")) - delta
			if timer <= 0.0:
				unit.set_meta("attack_timer", 1.15)
				target.set_meta("hp", float(target.get_meta("hp")) - 22.0)
				_spawn_hit_spark(target.global_position)
				if float(target.get_meta("hp")) <= 0.0:
					opponents.erase(target)
					target.queue_free()
			else:
				unit.set_meta("attack_timer", timer)
		else:
			unit.position.x += direction * 2.45 * delta
			if blue_attacking and unit.position.x >= 41.5:
				red_core_hp = maxf(0.0, red_core_hp - 12.0 * delta)
			elif not blue_attacking and unit.position.x <= -41.5:
				blue_core_hp = maxf(0.0, blue_core_hp - 12.0 * delta)

func _nearest_unit(from: Node3D, units: Array[Node3D], max_range: float) -> Node3D:
	var best: Node3D = null
	var best_distance := max_range
	for unit in units:
		if not is_instance_valid(unit):
			continue
		var d := from.global_position.distance_to(unit.global_position)
		if d < best_distance:
			best_distance = d
			best = unit
	return best

func _update_neutral_monsters(delta: float) -> void:
	for monster in neutral_monsters.duplicate():
		if not is_instance_valid(monster):
			neutral_monsters.erase(monster)
			continue
		if float(monster.get_meta("hp")) <= 0.0:
			neutral_monsters.erase(monster)
			_spawn_hit_spark(monster.global_position + Vector3(0, 1.0, 0))
			monster.queue_free()
			continue
		var phase := float(monster.get_meta("phase"))
		monster.rotation.y += delta * 0.22
		monster.position.y = sin(game_time * 1.8 + phase) * 0.06

func _basic_attack() -> void:
	if attack_cooldown > 0.0:
		return
	attack_cooldown = 0.58
	attack_anim_timer = 0.24
	var target := _nearest_attack_target(ATTACK_RANGE)
	if target != null:
		_damage_target(target, ATTACK_DAMAGE)
		_spawn_wind_fx(hero.global_position + Vector3(0, 1.0, 0), 1.5, 0.34)
		_show_message("Sword strike  |  -38 HP", 1.0)
	else:
		_show_message("No target in sword range", 0.8)

func _cast_skill() -> void:
	if skill_cooldown > 0.0:
		return
	skill_cooldown = 5.0
	var center := hero.global_position
	var hit_count := 0
	for target in enemies.duplicate():
		if is_instance_valid(target) and center.distance_to(target.global_position) <= 10.5:
			_damage_target(target, SKILL_DAMAGE)
			hit_count += 1
	for target in neutral_monsters.duplicate():
		if is_instance_valid(target) and center.distance_to(target.global_position) <= 10.5:
			_damage_target(target, SKILL_DAMAGE)
			hit_count += 1
	_spawn_wind_fx(center + Vector3(0, 0.22, 0), 4.1, 0.62)
	_show_message("Q  |  WIND NOVA  |  Hit %d targets" % hit_count, 1.5)

func _nearest_attack_target(max_range: float) -> Node3D:
	var best: Node3D = null
	var best_distance := max_range
	for target in enemies:
		if not is_instance_valid(target):
			continue
		var d := hero.global_position.distance_to(target.global_position)
		if d < best_distance:
			best_distance = d
			best = target
	for target in neutral_monsters:
		if not is_instance_valid(target):
			continue
		var d := hero.global_position.distance_to(target.global_position)
		if d < best_distance:
			best_distance = d
			best = target
	return best

func _damage_target(target: Node3D, amount: float) -> void:
	target.set_meta("hp", float(target.get_meta("hp")) - amount)
	target.scale = target.scale * 0.94
	_spawn_hit_spark(target.global_position + Vector3(0, 1.0, 0))
	if float(target.get_meta("hp")) <= 0.0:
		if enemies.has(target):
			enemies.erase(target)
		if neutral_monsters.has(target):
			neutral_monsters.erase(target)
		target.queue_free()

func _spawn_wind_fx(pos: Vector3, radius: float, duration: float) -> void:
	var fx := Node3D.new()
	fx.name = "WindSlashEffect"
	fx.position = pos
	fx.set_meta("life", duration)
	fx.set_meta("duration", duration)
	for i in range(3):
		var ring := MeshInstance3D.new()
		var torus := TorusMesh.new()
		torus.inner_radius = radius * (0.72 + float(i) * 0.14)
		torus.outer_radius = torus.inner_radius + 0.055
		ring.mesh = torus
		ring.rotation_degrees.x = 90.0
		ring.rotation_degrees.y = float(i) * 28.0
		var material := StandardMaterial3D.new()
		material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		material.albedo_color = Color(0.24, 0.82, 1.0, 0.76)
		material.emission_enabled = true
		material.emission = Color(0.08, 0.55, 1.0)
		material.emission_energy_multiplier = 1.8
		ring.material_override = material
		fx.add_child(ring)
	add_child(fx)
	active_fx.append(fx)

func _spawn_hit_spark(pos: Vector3) -> void:
	var spark := MeshInstance3D.new()
	var mesh := SphereMesh.new()
	mesh.radius = 0.18
	mesh.height = 0.36
	spark.mesh = mesh
	spark.position = pos
	spark.material_override = _mat_emissive(Color(0.58, 0.9, 1.0), Color(0.18, 0.68, 1.0))
	add_child(spark)
	var timer := get_tree().create_timer(0.22)
	timer.timeout.connect(func(): if is_instance_valid(spark): spark.queue_free())

func _update_fx(delta: float) -> void:
	for fx in active_fx.duplicate():
		if not is_instance_valid(fx):
			active_fx.erase(fx)
			continue
		var life := float(fx.get_meta("life")) - delta
		fx.set_meta("life", life)
		var duration := float(fx.get_meta("duration"))
		var progress := 1.0 - clampf(life / duration, 0.0, 1.0)
		fx.scale = Vector3.ONE * (0.7 + progress * 0.85)
		fx.rotation.y += delta * 2.8
		for child in fx.get_children():
			var mesh := child as MeshInstance3D
			if mesh and mesh.material_override is StandardMaterial3D:
				var material := mesh.material_override as StandardMaterial3D
				var tint := material.albedo_color
				tint.a = 0.76 * (1.0 - progress)
				material.albedo_color = tint
		if life <= 0.0:
			active_fx.erase(fx)
			fx.queue_free()

func _build_hud() -> void:
	var layer := CanvasLayer.new()
	layer.name = "GameHUD"
	add_child(layer)
	hud = Label.new()
	hud.position = Vector2(24, 20)
	hud.add_theme_font_size_override("font_size", 21)
	hud.add_theme_color_override("font_color", Color(0.9, 0.96, 1.0))
	layer.add_child(hud)
	status_label = Label.new()
	status_label.position = Vector2(24, 92)
	status_label.add_theme_font_size_override("font_size", 19)
	status_label.add_theme_color_override("font_color", Color(0.55, 0.9, 1.0))
	layer.add_child(status_label)
	var help := Label.new()
	help.text = "WASD MOVE   |   SPACE SWORD   |   Q WIND NOVA   |   R RESTART"
	help.position = Vector2(24, 850)
	help.add_theme_font_size_override("font_size", 18)
	help.add_theme_color_override("font_color", Color(0.92, 0.96, 1.0))
	layer.add_child(help)

func _update_hud() -> void:
	if hud:
		hud.text = "HONOR MOBA  |  BLUE CORE %.0f  |  RED CORE %.0f  |  RED MINIONS %d  |  Q %.1fs" % [blue_core_hp, red_core_hp, enemies.size(), skill_cooldown]
	if status_label and not game_over and status_timer <= 0.0:
		var jungle_count := neutral_monsters.size()
		status_label.text = "WIND RONIN  |  HP 500  |  JUNGLE MONSTERS %d  |  BASIC %.1fs" % [jungle_count, attack_cooldown]

func _show_message(message: String, duration: float = 1.3) -> void:
	if status_label:
		status_label.text = message
		status_timer = duration

func _update_camera(delta: float) -> void:
	if camera == null or hero == null:
		return
	var desired := hero.global_position + Vector3(0, 23, 20)
	camera.global_position = camera.global_position.lerp(desired, 1.0 - exp(-5.5 * delta))
	camera.look_at(hero.global_position + Vector3(0, 0.6, 0), Vector3.UP)

func _make_tower(tower_name: String, pos: Vector3, color: Color) -> void:
	var tower := Node3D.new()
	tower.name = tower_name
	tower.position = pos
	var base := MeshInstance3D.new()
	var cylinder := CylinderMesh.new()
	cylinder.top_radius = 0.78
	cylinder.bottom_radius = 1.24
	cylinder.height = 2.6
	base.mesh = cylinder
	base.position.y = 1.3
	base.material_override = _mat(color.darkened(0.15))
	tower.add_child(base)
	var crown := MeshInstance3D.new()
	var orb := SphereMesh.new()
	orb.radius = 0.65
	orb.height = 1.3
	crown.mesh = orb
	crown.position.y = 2.85
	crown.material_override = _mat_emissive(color.lightened(0.28), color)
	tower.add_child(crown)
	var light := OmniLight3D.new()
	light.position.y = 3.0
	light.light_color = color
	light.light_energy = 0.75
	light.omni_range = 7.0
	tower.add_child(light)
	add_child(tower)

func _make_tree(pos: Vector3) -> void:
	var trunk := MeshInstance3D.new()
	var trunk_mesh := CylinderMesh.new()
	trunk_mesh.top_radius = 0.2
	trunk_mesh.bottom_radius = 0.42
	trunk_mesh.height = 2.4
	trunk.mesh = trunk_mesh
	trunk.position = pos + Vector3(0, 1.2, 0)
	trunk.material_override = _mat(Color(0.22, 0.13, 0.08))
	add_child(trunk)
	for i in range(3):
		var leaves := MeshInstance3D.new()
		var crown := SphereMesh.new()
		crown.radius = 1.5 - float(i) * 0.12
		crown.height = 2.8 - float(i) * 0.15
		leaves.mesh = crown
		leaves.position = pos + Vector3((float(i) - 1.0) * 0.55, 2.8 + float(i) * 0.35, 0)
		leaves.material_override = _mat(Color(0.055, 0.23 + float(i) * 0.025, 0.12))
		add_child(leaves)

func _make_bush(pos: Vector3) -> void:
	for i in range(3):
		var bush := MeshInstance3D.new()
		var mesh := SphereMesh.new()
		mesh.radius = 0.78
		mesh.height = 1.1
		bush.mesh = mesh
		bush.position = pos + Vector3((float(i) - 1.0) * 0.72, 0.55, 0)
		bush.material_override = _mat(Color(0.08, 0.27 + float(i) * 0.03, 0.12))
		add_child(bush)

func _add_box(label: String, pos: Vector3, size: Vector3, color: Color, solid: bool = true, textured: bool = false) -> void:
	var parent: Node3D
	if solid:
		parent = StaticBody3D.new()
	else:
		parent = Node3D.new()
	parent.name = label
	parent.position = pos
	var mesh_node := MeshInstance3D.new()
	mesh_node.name = "Visual"
	var box := BoxMesh.new()
	box.size = size
	mesh_node.mesh = box
	mesh_node.material_override = _terrain_material() if textured else _mat(color)
	parent.add_child(mesh_node)
	if solid:
		var collision := CollisionShape3D.new()
		var shape := BoxShape3D.new()
		shape.size = size
		collision.shape = shape
		parent.add_child(collision)
	add_child(parent)

func _terrain_material() -> ShaderMaterial:
	var material := ShaderMaterial.new()
	material.shader = GroundShader
	material.set_shader_parameter("grass_dark", Color(0.035, 0.12, 0.075))
	material.set_shader_parameter("grass_light", Color(0.16, 0.29, 0.13))
	material.set_shader_parameter("texture_scale", 95.0)
	return material

func _mat(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.84
	return material

func _mat_emissive(color: Color, glow: Color) -> StandardMaterial3D:
	var material := _mat(color)
	material.emission_enabled = true
	material.emission = glow
	material.emission_energy_multiplier = 1.5
	return material

func _initialize_input_actions() -> void:
	_add_key_action("move_left", KEY_A)
	_add_key_action("move_right", KEY_D)
	_add_key_action("move_forward", KEY_W)
	_add_key_action("move_back", KEY_S)
	_add_key_action("attack", KEY_SPACE)
	_add_key_action("skill", KEY_Q)
	_add_key_action("restart", KEY_R)

func _add_key_action(action: String, keycode: Key) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)
	var event := InputEventKey.new()
	event.physical_keycode = keycode
	InputMap.action_add_event(action, event)

func _enter_tree() -> void:
	_initialize_input_actions()
