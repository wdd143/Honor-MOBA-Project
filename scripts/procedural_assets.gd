extends RefCounted
class_name ProceduralAssets

static func make_hero() -> Node3D:
	var root := Node3D.new()
	root.name = "OriginalWindRonin"
	var dark := _material(Color(0.055, 0.09, 0.16), 0.72)
	var blue := _material(Color(0.06, 0.28, 0.66), 0.55)
	var bright := _material(Color(0.16, 0.72, 1.0), 0.35, Color(0.04, 0.22, 0.55))
	var skin := _material(Color(0.82, 0.62, 0.46), 0.85)
	var metal := _material(Color(0.62, 0.76, 0.86), 0.28, Color(0.08, 0.14, 0.2))
	var cloth := _material(Color(0.78, 0.86, 0.94), 0.8)

	var torso := Node3D.new()
	torso.name = "TorsoPivot"
	torso.position.y = 0.05
	root.add_child(torso)
	var chest := CapsuleMesh.new()
	chest.radius = 0.38
	chest.height = 1.0
	_piece(torso, "ArmoredCoat", chest, Vector3(0, 0.05, 0), blue)
	_piece(torso, "ChestPlate", _box(Vector3(0.58, 0.42, 0.16)), Vector3(0, 0.12, -0.31), metal)
	_piece(torso, "Belt", _box(Vector3(0.82, 0.13, 0.48)), Vector3(0, -0.38, 0), dark)
	_piece(torso, "ShoulderGuard", _box(Vector3(0.9, 0.2, 0.52)), Vector3(0, 0.47, 0), dark)

	var head := Node3D.new()
	head.name = "Head"
	head.position = Vector3(0, 0.78, 0)
	torso.add_child(head)
	var head_mesh := SphereMesh.new()
	head_mesh.radius = 0.27
	head_mesh.height = 0.54
	_piece(head, "Face", head_mesh, Vector3.ZERO, skin)
	_piece(head, "Hair", _box(Vector3(0.52, 0.22, 0.52)), Vector3(0, 0.24, 0.02), dark)
	_piece(head, "Headband", _box(Vector3(0.58, 0.07, 0.57)), Vector3(0, 0.08, -0.02), bright)

	var left_arm := _limb(root, "LeftArmPivot", Vector3(-0.48, 0.38, 0), 0.66, blue)
	var right_arm := _limb(root, "RightArmPivot", Vector3(0.48, 0.38, 0), 0.66, blue)
	_piece(left_arm, "LeftGauntlet", _box(Vector3(0.2, 0.26, 0.23)), Vector3(0, -0.33, -0.02), metal)
	_piece(right_arm, "RightGauntlet", _box(Vector3(0.2, 0.26, 0.23)), Vector3(0, -0.33, -0.02), metal)

	var left_leg := _limb(root, "LeftLegPivot", Vector3(-0.22, -0.48, 0), 0.74, dark)
	var right_leg := _limb(root, "RightLegPivot", Vector3(0.22, -0.48, 0), 0.74, dark)
	_piece(left_leg, "Boot", _box(Vector3(0.32, 0.2, 0.48)), Vector3(0, -0.35, -0.08), blue)
	_piece(right_leg, "Boot", _box(Vector3(0.32, 0.2, 0.48)), Vector3(0, -0.35, -0.08), blue)

	var sword_pivot := Node3D.new()
	sword_pivot.name = "SwordPivot"
	sword_pivot.position = Vector3(0.52, 0.08, -0.04)
	root.add_child(sword_pivot)
	_piece(sword_pivot, "Blade", _box(Vector3(0.105, 1.38, 0.07)), Vector3(0, 0.53, -0.12), metal)
	_piece(sword_pivot, "BladeGlow", _box(Vector3(0.035, 1.08, 0.075)), Vector3(0, 0.58, -0.16), bright)
	_piece(sword_pivot, "CrossGuard", _box(Vector3(0.42, 0.075, 0.12)), Vector3(0, -0.16, -0.12), bright)
	_piece(sword_pivot, "Grip", _cylinder(0.055, 0.32), Vector3(0, -0.34, -0.12), dark)

	var scarf := Node3D.new()
	scarf.name = "ScarfPivot"
	scarf.position = Vector3(-0.2, 0.48, 0.22)
	root.add_child(scarf)
	_piece(scarf, "ScarfTail", _box(Vector3(0.22, 0.9, 0.09)), Vector3(-0.12, -0.35, 0.28), cloth)
	_piece(scarf, "ScarfTip", _box(Vector3(0.2, 0.3, 0.09)), Vector3(-0.12, -0.86, 0.28), bright)

	return root

static func animate_hero(root: Node3D, time: float, moving: bool, attacking: bool) -> void:
	var amount := 1.0 if moving else 0.18
	var stride := sin(time * 10.0) * 0.48 * amount
	var left_leg := root.get_node_or_null("LeftLegPivot") as Node3D
	var right_leg := root.get_node_or_null("RightLegPivot") as Node3D
	var left_arm := root.get_node_or_null("LeftArmPivot") as Node3D
	var right_arm := root.get_node_or_null("RightArmPivot") as Node3D
	var sword := root.get_node_or_null("SwordPivot") as Node3D
	var scarf := root.get_node_or_null("ScarfPivot") as Node3D
	if left_leg:
		left_leg.rotation.x = stride
	if right_leg:
		right_leg.rotation.x = -stride
	if left_arm:
		left_arm.rotation.x = -stride * 0.65
	if right_arm:
		right_arm.rotation.x = stride * 0.65
	if sword:
		sword.rotation.z = -0.75 if attacking else 0.0
		sword.rotation.x = -0.12 + sin(time * 2.4) * 0.035
	if scarf:
		scarf.rotation.z = sin(time * 4.0) * 0.12 + (0.22 if moving else 0.0)

static func make_minion(blue_team: bool) -> Node3D:
	var root := Node3D.new()
	root.name = "BlueLaneSoldier" if blue_team else "RedLaneSoldier"
	var team := _material(Color(0.08, 0.34, 0.88) if blue_team else Color(0.72, 0.12, 0.1), 0.55)
	var trim := _material(Color(0.55, 0.78, 1.0) if blue_team else Color(1.0, 0.55, 0.3), 0.3)
	var dark := _material(Color(0.12, 0.14, 0.18), 0.8)
	var body := Node3D.new()
	body.name = "BodyPivot"
	root.add_child(body)
	_piece(body, "Armor", _box(Vector3(0.72, 0.84, 0.48)), Vector3(0, 0.82, 0), team)
	_piece(body, "Helmet", _sphere(0.34), Vector3(0, 1.48, 0), trim)
	_piece(body, "Visor", _box(Vector3(0.48, 0.1, 0.38)), Vector3(0, 1.46, -0.2), dark)
	_piece(body, "LeftLeg", _box(Vector3(0.2, 0.46, 0.25)), Vector3(-0.19, 0.23, 0.02), dark)
	_piece(body, "RightLeg", _box(Vector3(0.2, 0.46, 0.25)), Vector3(0.19, 0.23, 0.02), dark)
	_piece(body, "LeftBoot", _box(Vector3(0.28, 0.13, 0.38)), Vector3(-0.19, 0.05, -0.05), trim)
	_piece(body, "RightBoot", _box(Vector3(0.28, 0.13, 0.38)), Vector3(0.19, 0.05, -0.05), trim)
	_piece(body, "LeftArm", _box(Vector3(0.2, 0.55, 0.22)), Vector3(-0.48, 0.77, 0), team)
	_piece(body, "RightArm", _box(Vector3(0.2, 0.55, 0.22)), Vector3(0.48, 0.77, 0), team)
	_piece(body, "Shield", _box(Vector3(0.38, 0.58, 0.13)), Vector3(-0.5, 0.82, -0.12), trim)
	_piece(body, "Spear", _cylinder(0.045, 1.45), Vector3(0.5, 0.98, -0.18), dark)
	_piece(body, "SpearHead", _cone(0.11, 0.28), Vector3(0.5, 1.82, -0.18), trim)
	return root

static func make_golem() -> Node3D:
	var root := Node3D.new()
	root.name = "AncientMossGolem"
	var stone := _material(Color(0.24, 0.31, 0.29), 0.95)
	var moss := _material(Color(0.13, 0.38, 0.22), 1.0)
	var crystal := _material(Color(0.12, 0.8, 0.75), 0.24, Color(0.02, 0.42, 0.4))
	_piece(root, "Body", _sphere(0.95), Vector3(0, 1.0, 0), stone)
	_piece(root, "ChestRock", _box(Vector3(1.25, 0.8, 0.8)), Vector3(0, 1.15, -0.48), moss)
	_piece(root, "Head", _sphere(0.48), Vector3(0, 2.03, -0.06), stone)
	_piece(root, "LeftEye", _sphere(0.12), Vector3(-0.2, 2.1, -0.48), crystal)
	_piece(root, "RightEye", _sphere(0.12), Vector3(0.2, 2.1, -0.48), crystal)
	_piece(root, "LeftHorn", _cone(0.2, 0.62), Vector3(-0.42, 2.52, 0), moss)
	_piece(root, "RightHorn", _cone(0.2, 0.62), Vector3(0.42, 2.52, 0), moss)
	_piece(root, "LeftArm", _sphere(0.48), Vector3(-1.0, 1.0, 0), stone)
	_piece(root, "RightArm", _sphere(0.48), Vector3(1.0, 1.0, 0), stone)
	_piece(root, "CrystalCore", _sphere(0.22), Vector3(0, 1.18, -0.9), crystal)
	return root

static func _limb(parent: Node3D, node_name: String, pos: Vector3, length: float, material: Material) -> Node3D:
	var pivot := Node3D.new()
	pivot.name = node_name
	pivot.position = pos
	parent.add_child(pivot)
	_piece(pivot, "Limb", _cylinder(0.13, length), Vector3(0, -length * 0.42, 0), material)
	return pivot

static func _piece(parent: Node3D, node_name: String, mesh: Mesh, pos: Vector3, material: Material) -> MeshInstance3D:
	var instance := MeshInstance3D.new()
	instance.name = node_name
	instance.mesh = mesh
	instance.position = pos
	instance.material_override = material
	parent.add_child(instance)
	return instance

static func _box(size: Vector3) -> BoxMesh:
	var mesh := BoxMesh.new()
	mesh.size = size
	return mesh

static func _sphere(radius: float) -> SphereMesh:
	var mesh := SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius * 2.0
	return mesh

static func _cylinder(radius: float, height: float) -> CylinderMesh:
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = height
	return mesh

static func _cone(radius: float, height: float) -> CylinderMesh:
	var mesh := CylinderMesh.new()
	mesh.top_radius = 0.015
	mesh.bottom_radius = radius
	mesh.height = height
	return mesh

static func _material(color: Color, roughness: float, glow: Color = Color.BLACK) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = roughness
	if glow != Color.BLACK:
		material.emission_enabled = true
		material.emission = glow
	return material
