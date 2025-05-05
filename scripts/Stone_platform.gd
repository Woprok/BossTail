extends Node3D

@export var neighbors: Array[Node] = []
@export var neighborStonePlatform : Array[Node] = []
@export var radius = 11
@export var health = 2
@export var num = 0
var boulder1Position = Vector3(-2.5,1.15,3.5)
var boulder2Position = Vector3(3.5,1.15,-2.5)
