# Honor MOBA Project

An original 3D lane-based MOBA prototype built with Unity. The project takes inspiration from common MOBA gameplay structures, but uses original project code and placeholder visuals. It does not include proprietary game characters, maps, logos, music, voice lines or other copied game assets.

## Engine
- **Unity 6.3 LTS**
- Editor version: `6000.3.0f1`

## First milestone: 3D starter arena
The first milestone includes:
- Unity project structure (`Assets`, `Packages`, `ProjectSettings`)
- One-click scene generation from the Unity Editor
- Three greybox lanes, two team bases and six outer towers
- Simple jungle clearings and placeholder trees
- A controllable blue hero capsule
- Camera follow, health component and keyboard movement

## Create the starter scene
1. Open this repository as a Unity project in Unity Hub.
2. In the Unity Editor select **Honor MOBA > Create Starter Arena**.
3. Open `Assets/Scenes/MOBA_StarterArena.unity`.
4. Press Play and move with **WASD** or the **arrow keys**.

See [Docs/FIRST_OPEN.md](Docs/FIRST_OPEN.md) for setup instructions and input troubleshooting.

## Code layout
- `Assets/Scripts/Core`: teams and shared game types
- `Assets/Scripts/Combat`: health and combat foundations
- `Assets/Scripts/Hero`: hero movement and input
- `Assets/Scripts/Camera`: camera follow
- `Assets/Editor`: editor tools for generating test scenes
- `Docs`: roadmap and setup notes

## Important
This repository contains the Unity source project, not a ready-to-install Android game. The Unity Editor currently needs to be run on a Windows or macOS computer to generate the scene, test gameplay and build a device version. The scene is a greybox prototype; art, animation, minions, skills, items, AI and mobile controls will be developed in later milestones.
