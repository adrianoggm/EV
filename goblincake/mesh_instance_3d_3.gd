extends MeshInstance3D

func _ready():
	# Se crea un ArrayMesh que contendrá la geometría del cubo.
	var cube_mesh = ArrayMesh.new()
	
	# Definiiode los 8 vértices del cubo L=2
	var vertices = PackedVector3Array([
		Vector3(-1, -1, -1), # v0
		Vector3( 1, -1, -1), # v1
		Vector3( 1,  1, -1), # v2
		Vector3(-1,  1, -1), # v3
		Vector3(-1, -1,  1), # v4
		Vector3( 1, -1,  1), # v5
		Vector3( 1,  1,  1), # v6
		Vector3(-1,  1,  1)  # v7
	])
	#       v3 ----- v7
	# 	 /     \     /
	#  V2 ------- v6 |                  
	#  |   |         |
	#  |  V0------  v4
	#  | /     \    / 
	#  V1 --------v5

	# Definición de las caras del cubo mediante índices.
	# Cada cara se compone de 2 triángulos.
	var indices = PackedInt32Array([
		# Cara izq
		0, 1, 2,
		2, 3, 0,
		
		# Cara derecha 
		4, 6, 5,
		4, 7, 6,
		
		# Cara trasera (x = -1)
		0, 3, 7,
		7, 4, 0,
		
		# Cara frontal
		1, 5, 6,
		6, 2, 1,
		
		# Cara inferior (y = -1)
		0, 5, 1,
		5, 0, 4,
		
		# Cara superior (y = +1)
		3, 2, 6,
		6, 7, 3
	])
	
	# Se prepara el array de arrays para el ArrayMesh.
	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_INDEX] = indices
	cube_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	# Se asigna el mesh generado al nodo.
	mesh = cube_mesh
