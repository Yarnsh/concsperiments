## Collision layers

### 1
Static geometry like the map, every body on this layer is expected to have `collider_material.gd` as a script.

### 2
Character bodies, specifically the cylinder collider.

### 3
Character hitboxes, these are also expected to have `collider_material.gd` as a script.

### 4
Anything that recieves "noise alerts", all bodies on this level should have the "noise_alert" method.
