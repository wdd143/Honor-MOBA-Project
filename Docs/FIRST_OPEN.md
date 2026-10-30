# Open the project for the first time

## On a Windows or macOS computer
1. Install Unity Hub from the official Unity website.
2. In Unity Hub, install **Unity 6.3 LTS** (Editor version 6000.3.0f1).
3. Download this repository as a ZIP, or clone it with Git.
4. In Unity Hub choose **Add > Add project from disk** and select the folder that contains `Assets`, `Packages` and `ProjectSettings`.
5. Wait for Unity to import the project.
6. In the Unity menu choose **Honor MOBA > Create Starter Arena**.
7. Open `Assets/Scenes/MOBA_StarterArena.unity` if it is not already open.
8. Press Play. Use **WASD** or the **arrow keys** to move the blue capsule hero.

## If keyboard input does not respond
Open **Edit > Project Settings > Player > Other Settings** and set **Active Input Handling** to **Both** (or **Input Manager (Old)**), then restart the Editor.

## Current milestone
This is a playable greybox foundation only. The arena uses Unity primitive shapes. It does not yet contain production character models, textures, skill effects, minion waves, shops, networking or mobile UI.
