## Checks if that player can interact with the object [br]
## @deprecated: switch to InteractableRigidBody3D
class_name CheckInteractable extends CollisionShape3D

## Which player that cannot interact
@export var player_type: PlayerController.PlayerType
var is_picked_up: bool

# TODO: Easier to make this into InteractableRigidBody3D
