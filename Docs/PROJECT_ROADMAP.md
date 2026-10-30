# 3D MOBA Project Roadmap

This repository is the foundation for an original 3D lane-based MOBA prototype.

## Scope
- Third-person/isometric arena camera
- Three lanes, jungle areas, towers, minions and two team bases
- Playable original heroes with movement, basic attacks and skills
- Gold, experience, items and respawn loop
- Simple AI for minions and practice opponents
- Mobile-friendly controls as a later milestone

This project may take inspiration from common MOBA gameplay conventions. It will use original names, characters, models, UI and audio. Do not copy proprietary game assets, maps, logos, voice lines or character designs without permission.

## Milestones
1. **Foundation:** Unity project structure, teams, health, hero movement and camera follow.
2. **Arena:** greybox map, three lanes, bases, towers and navigation blockers.
3. **Combat:** basic attacks, damage, skills, cooldowns and death/respawn.
4. **Minions and AI:** lane waves, target selection, tower aggro and simple bots.
5. **Progression:** gold, experience, shop and item stats.
6. **Polish:** original art, animation, sound, UI, optimization and testing.

## Unity setup
Create a Unity 3D project, then copy the `Assets/` folder from this repository into the project. The starter scripts use Unity's built-in `CharacterController` and do not require third-party packages.

The scripts are a code foundation, not a complete playable game. Scene objects, prefabs, materials, animations and input bindings still need to be created in the Unity Editor.
