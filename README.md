# Honor MOBA — Godot 4 Edition

An original 3D lane-based MOBA prototype for **Godot 4.x**. The project is moving from a primitive gameplay test toward an original fantasy arena game.

## Run it

1. Install the free Godot 4.x Standard desktop editor.
2. Download this repository as a ZIP and extract it.
3. In Godot, choose **Import**, select this folder's project.godot, then open it.
4. Press **F5** to run the project (or **F6** to run the current main scene).

## Controls

- **W A S D** — move
- **Space** — sword attack against the nearest enemy minion or jungle monster
- **Q** — Wind Nova area skill
- **R** — restart after a core is destroyed

## Current build

- 3D three-lane arena, blue and red bases, towers and a follow camera
- Collision on the arena floor, lanes and base platforms
- Original procedural Wind Ronin hero with armor, scarf, sword and basic movement/attack animation
- Blue and red lane soldiers with simple automated waves and combat
- Two jungle monster camps with large/small Ancient Moss Golems
- Wind Nova rings, sword-hit sparks, cooldown HUD and core health
- Procedural terrain shader, stylized foliage, lighting, sky and distance fog

## Important asset status

The characters and effects in this build are **first-pass procedural models made from primitive meshes**. They are not yet production-grade imported 3D models, and the hero does not yet have a skeletal rig. The project now includes an asset pipeline guide for adding licensed GLB/glTF characters, animations and PBR textures from sources such as Quaternius, KayKit and Poly Haven.

No League of Legends or Honor of Kings extracted assets are included. See docs/ASSET_PIPELINE.md for the planned licensed asset workflow.

## Testing note

The source files have been updated for Godot 4, but this environment cannot launch the Godot editor to confirm a live runtime. Please import the project in Godot 4 and check the Output panel for errors on first launch.
