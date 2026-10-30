# Asset pipeline and licenses

This project is being built as an original MOBA prototype. It does not use League of Legends or Honor of Kings character files, maps, icons, audio, or extracted game data.

## Current state

The current prototype creates its first-pass characters, lane soldiers, jungle golems, towers, foliage, and wind effects from Godot primitive meshes and materials in code. These are editable placeholders, not finished sculpted models and not skeletal/rigged models.

## Planned asset folders

- assets/models/hero — original wind-swordsman hero in GLB/glTF format
- assets/models/minions — blue and red lane soldier models
- assets/models/monsters — jungle camps, large and small monsters
- assets/animations — idle, walk, run, sword attack, hit and death clips
- assets/textures — terrain, stone, armor, cloth, foliage and monster PBR maps
- assets/fx — wind slashes, impact bursts and skill textures

Godot imports glTF/GLB models directly. Prefer GLB for a self-contained model with materials and animation.

## Legal asset sources to use

1. **Quaternius** — https://quaternius.com/  
   Look for the animated character, monster/bestiary, medieval/fantasy prop and nature packs. Check the license shown on the exact pack page before copying files into this project. Quaternius describes its free packs as CC0; retain a copy of the pack's license information in the project when assets are added.
2. **KayKit Character Animations** — https://kaylousberg.itch.io/kaykit-character-animations  
   The publisher describes the FBX/GLTF animation assets as CC0 and suitable for Godot. Use them only with a compatible rig or after retargeting.
3. **Poly Haven** — https://polyhaven.com/  
   Poly Haven states that its models, textures and HDRIs are CC0. It is a suitable source for high-resolution PBR ground, rock, stone, wood and environment materials.

## Import checklist

For every imported asset:

1. Download it from the publisher's own page.
2. Keep the original filename and add a short entry in ASSET_CREDITS.md with its source URL, creator, license and download date.
3. Place the GLB/GLTF file in the matching folder above.
4. Open the project in Godot so the editor can import it.
5. Confirm scale, orientation, materials, skeleton and animation names before replacing the procedural placeholder.
6. Keep texture sizes sensible: use 2K/4K for most gameplay assets and reserve 8K maps for large hero shots or special close-ups.

## Next production stages

- Replace the procedural wind ronin with a rigged original hero model; connect idle, locomotion, attack, hit and death animations.
- Replace the primitive lane soldiers with two team variants and readable silhouettes.
- Add a large and small monster for each jungle camp, with idle, alert, attack and death states.
- Upgrade the arena with tiled PBR textures, height/normal maps, cliff pieces, river, brush and lane props.
- Replace prototype rings with animated mesh/particle VFX and impact decals.

No external binary art pack has been copied into the repository in this pass. The source list above is the planned legal asset pipeline; the current procedural assets are already in the project.
