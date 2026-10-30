extends Node3D

const HERO_SPEED := 9.0
const ATTACK_RANGE := 8.0
const ATTACK_DAMAGE := 35.0
const SKILL_DAMAGE := 75.0

var hero: CharacterBody3D
var camera: Camera3D
var hud: Label
var status_label: Label
var enemies: Array[Node3D] = []
var allies: Array[Node3D] = []
var blue_core_hp := 1000.0
var red_core_hp := 1000.0
var attack_cooldown := 0.0
var skill_cooldown := 0.0
var game_over := false

func _ready() -> void:
    _build_arena()
    _spawn_hero()
    _spawn_waves()
    _build_hud()
    _update_hud()

func _process(delta: float) -> void:
    attack_cooldown = maxf(0.0, attack_cooldown - delta)
    skill_cooldown = maxf(0.0, skill_cooldown - delta)
    if not game_over:
        _update_minions(delta)
    _update_camera(delta)
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
    _add_box("Ground", Vector3(0, -0.7, 0), Vector3(100, 1, 72), Color(0.10, 0.22, 0.16))
    for z in [-23.0, 0.0, 23.0]:
        _add_box("Stone Lane", Vector3(0, -0.08, z), Vector3(86, 0.25, 7), Color(0.38, 0.40, 0.39))
        for x in range(-38, 39, 8):
            _add_box("Lane Mark", Vector3(float(x), 0.06, z), Vector3(0.35, 0.04, 0.25), Color(0.72, 0.70, 0.57))
    _add_box("Blue Base", Vector3(-43, 0.0, 0), Vector3(12, 0.8, 32), Color(0.08, 0.22, 0.58))
    _add_box("Red Base", Vector3(43, 0.0, 0), Vector3(12, 0.8, 32), Color(0.55, 0.10, 0.10))
    _make_tower("Blue Core", Vector3(-45, 1.0, 0), Color(0.12, 0.55, 1.0))
    _make_tower("Red Core", Vector3(45, 1.0, 0), Color(1.0, 0.20, 0.12))
    for z in [-23.0, 0.0, 23.0]:
        _make_tower("Blue Tower", Vector3(-25, 1.0, z), Color(0.12, 0.55, 1.0))
        _make_tower("Red Tower", Vector3(25, 1.0, z), Color(1.0, 0.20, 0.12))
    for x in [-14.0, 0.0, 14.0]:
        for z in [-12.0, 12.0]:
            _make_tree(Vector3(x, 0, z))
    var light := DirectionalLight3D.new()
    light.rotation_degrees = Vector3(-52, -30, 0)
    light.light_energy = 1.25
    add_child(light)
    var world := WorldEnvironment.new()
    var env := Environment.new()
    env.background_mode = Environment.BG_SKY
    env.sky = Sky.new()
    env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    env.ambient_light_color = Color(0.45, 0.52, 0.62)
    env.ambient_light_energy = 0.65
    world.environment = env
    add_child(world)

func _spawn_hero() -> void:
    hero = CharacterBody3D.new()
    hero.name = "Blue Hero"
    hero.position = Vector3(-34, 1.2, 0)
    var shape := CapsuleShape3D.new()
    shape.radius = 0.65
    shape.height = 2.2
    var collision := CollisionShape3D.new()
    collision.shape = shape
    hero.add_child(collision)
    var mesh := MeshInstance3D.new()
    var capsule := CapsuleMesh.new()
    capsule.radius = 0.65
    capsule.height = 2.2
    mesh.mesh = capsule
    mesh.material_override = _mat(Color(0.10, 0.48, 1.0))
    hero.add_child(mesh)
    var marker := MeshInstance3D.new()
    var ring := CylinderMesh.new()
    ring.top_radius = 0.9
    ring.bottom_radius = 0.9
    ring.height = 0.08
    marker.mesh = ring
    marker.position.y = -1.0
    marker.material_override = _mat(Color(0.15, 0.8, 1.0))
    hero.add_child(marker)
    add_child(hero)
    camera = Camera3D.new()
    camera.current = true
    camera.fov = 55
    add_child(camera)
    camera.position = hero.position + Vector3(0, 24, 19)
    camera.look_at(hero.position, Vector3.UP)

func _spawn_waves() -> void:
    for lane_z in [-23.0, 0.0, 23.0]:
        for i in range(3):
            _make_minion(Vector3(-32.0 - i * 2.0, 0.9, lane_z), true)
            _make_minion(Vector3(32.0 + i * 2.0, 0.9, lane_z), false)

func _make_minion(pos: Vector3, blue: bool) -> void:
    var unit := Node3D.new()
    unit.name = "Blue Minion" if blue else "Red Minion"
    unit.position = pos
    unit.set_meta("blue", blue)
    unit.set_meta("hp", 100.0)
    unit.set_meta("attack_timer", 0.0)
    var body := MeshInstance3D.new()
    var mesh := BoxMesh.new()
    mesh.size = Vector3(0.9, 1.5, 0.9)
    body.mesh = mesh
    body.position.y = 0.75
    body.material_override = _mat(Color(0.12, 0.5, 1.0) if blue else Color(0.95, 0.18, 0.12))
    unit.add_child(body)
    var head := MeshInstance3D.new()
    var sphere := SphereMesh.new()
    sphere.radius = 0.38
    sphere.height = 0.76
    head.mesh = sphere
    head.position.y = 1.75
    head.material_override = _mat(Color(0.72, 0.82, 0.95))
    unit.add_child(head)
    add_child(unit)
    if blue:
        allies.append(unit)
    else:
        enemies.append(unit)

func _update_minions(delta: float) -> void:
    for unit in enemies.duplicate():
        if not is_instance_valid(unit):
            enemies.erase(unit)
            continue
        var hp: float = unit.get_meta("hp")
        if hp <= 0:
            enemies.erase(unit)
            unit.queue_free()
            continue
        var target_x := -42.0
        var dx := target_x - unit.position.x
        if absf(dx) > 2.2:
            unit.position.x += signf(dx) * 2.0 * delta
        else:
            red_core_hp = maxf(0.0, red_core_hp - 0.0)
    for unit in allies.duplicate():
        if not is_instance_valid(unit):
            allies.erase(unit)
            continue
        if float(unit.get_meta("hp")) <= 0:
            allies.erase(unit)
            unit.queue_free()
            continue
        unit.position.x = minf(42.0, unit.position.x + 2.0 * delta)
    if red_core_hp <= 0 or blue_core_hp <= 0:
        game_over = true
        status_label.text = "GAME OVER  |  Press R to restart"

func _basic_attack() -> void:
    if attack_cooldown > 0:
        return
    attack_cooldown = 0.55
    var target := _nearest_enemy(ATTACK_RANGE)
    if target != null:
        _damage_minion(target, ATTACK_DAMAGE)
        _show_message("Basic attack  -35")

func _cast_skill() -> void:
    if skill_cooldown > 0:
        return
    skill_cooldown = 5.0
    var hit_count := 0
    for target in enemies:
        if is_instance_valid(target) and hero.global_position.distance_to(target.global_position) <= 10.0:
            _damage_minion(target, SKILL_DAMAGE)
            hit_count += 1
    _show_message("Q skill!  Hit %d enemies" % hit_count)

func _nearest_enemy(max_range: float) -> Node3D:
    var best: Node3D = null
    var best_distance := max_range
    for target in enemies:
        if not is_instance_valid(target):
            continue
        var d := hero.global_position.distance_to(target.global_position)
        if d < best_distance:
            best_distance = d
            best = target
    return best

func _damage_minion(target: Node3D, amount: float) -> void:
    target.set_meta("hp", float(target.get_meta("hp")) - amount)
    var body := target.get_child(0) as MeshInstance3D
    if body:
        body.scale = Vector3.ONE * 0.85
    if float(target.get_meta("hp")) <= 0:
        enemies.erase(target)
        target.queue_free()

func _build_hud() -> void:
    var layer := CanvasLayer.new()
    add_child(layer)
    hud = Label.new()
    hud.position = Vector2(24, 20)
    hud.add_theme_font_size_override("font_size", 22)
    hud.add_theme_color_override("font_color", Color(0.9, 0.96, 1))
    layer.add_child(hud)
    status_label = Label.new()
    status_label.position = Vector2(24, 100)
    status_label.add_theme_font_size_override("font_size", 20)
    status_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
    layer.add_child(status_label)
    var help := Label.new()
    help.text = "WASD move  |  SPACE basic attack  |  Q area skill  |  R restart"
    help.position = Vector2(24, 850)
    help.add_theme_font_size_override("font_size", 18)
    help.add_theme_color_override("font_color", Color.WHITE)
    layer.add_child(help)

func _update_hud() -> void:
    if hud:
        hud.text = "HONOR MOBA  |  Blue Core: %.0f  |  Red Core: %.0f  |  Enemies: %d  |  Q: %.1fs" % [blue_core_hp, red_core_hp, enemies.size(), skill_cooldown]
    if status_label and not game_over:
        status_label.text = "Hero HP: 500  |  Attack: %.1fs" % attack_cooldown

func _update_camera(delta: float) -> void:
    if camera == null or hero == null:
        return
    var desired := hero.global_position + Vector3(0, 24, 19)
    camera.global_position = camera.global_position.lerp(desired, 1.0 - exp(-5.0 * delta))
    camera.look_at(hero.global_position, Vector3.UP)

func _make_tower(label: String, pos: Vector3, color: Color) -> void:
    var tower := Node3D.new()
    tower.name = label
    tower.position = pos
    var base := MeshInstance3D.new()
    var cylinder := CylinderMesh.new()
    cylinder.top_radius = 0.85
    cylinder.bottom_radius = 1.35
    cylinder.height = 2.8
    base.mesh = cylinder
    base.material_override = _mat(color)
    tower.add_child(base)
    var orb := MeshInstance3D.new()
    var sphere := SphereMesh.new()
    sphere.radius = 0.75
    sphere.height = 1.5
    orb.mesh = sphere
    orb.position.y = 2.0
    orb.material_override = _mat(color.lightened(0.3))
    tower.add_child(orb)
    add_child(tower)

func _make_tree(pos: Vector3) -> void:
    var trunk := MeshInstance3D.new()
    var trunk_mesh := CylinderMesh.new()
    trunk_mesh.top_radius = 0.25
    trunk_mesh.bottom_radius = 0.45
    trunk_mesh.height = 2.2
    trunk.mesh = trunk_mesh
    trunk.position = pos + Vector3(0, 1.1, 0)
    trunk.material_override = _mat(Color(0.25, 0.15, 0.09))
    add_child(trunk)
    var leaves := MeshInstance3D.new()
    var crown := SphereMesh.new()
    crown.radius = 1.8
    crown.height = 3.2
    leaves.mesh = crown
    leaves.position = pos + Vector3(0, 3.0, 0)
    leaves.material_override = _mat(Color(0.08, 0.32, 0.16))
    add_child(leaves)

func _add_box(label: String, pos: Vector3, size: Vector3, color: Color) -> void:
    var node := MeshInstance3D.new()
    node.name = label
    var box := BoxMesh.new()
    box.size = size
    node.mesh = box
    node.position = pos
    node.material_override = _mat(color)
    add_child(node)

func _mat(color: Color) -> StandardMaterial3D:
    var material := StandardMaterial3D.new()
    material.albedo_color = color
    material.roughness = 0.82
    return material

func _show_message(message: String) -> void:
    if status_label:
        status_label.text = message

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
