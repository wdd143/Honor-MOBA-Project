using HonorMoba.CameraSystem;
using HonorMoba.Combat;
using HonorMoba.Hero;
using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEngine;
using UnityEngine.SceneManagement;

namespace HonorMoba.EditorTools
{
    /// <summary>
    /// Creates a greybox three-lane MOBA arena from Unity primitives.
    /// Run from the Unity menu: Honor MOBA > Create Starter Arena.
    /// </summary>
    public static class StarterArenaBuilder
    {
        private const string SceneFolder = "Assets/Scenes";
        private const string MaterialsFolder = "Assets/Materials";
        private const string ScenePath = SceneFolder + "/MOBA_StarterArena.unity";

        [MenuItem("Honor MOBA/Create Starter Arena")]
        public static void CreateStarterArena()
        {
            if (!EditorSceneManager.SaveCurrentModifiedScenesIfUserWantsTo())
                return;

            if (!AssetDatabase.IsValidFolder(SceneFolder))
                AssetDatabase.CreateFolder("Assets", "Scenes");
            if (!AssetDatabase.IsValidFolder(MaterialsFolder))
                AssetDatabase.CreateFolder("Assets", "Materials");

            Scene scene = EditorSceneManager.NewScene(
                NewSceneSetup.EmptyScene, NewSceneMode.Single);

            Material groundMat = MakeMaterial("Arena_Ground", new Color(0.20f, 0.29f, 0.22f));
            Material laneMat = MakeMaterial("Lane_Stone", new Color(0.40f, 0.42f, 0.39f));
            Material blueMat = MakeMaterial("Team_Blue", new Color(0.12f, 0.48f, 0.95f));
            Material redMat = MakeMaterial("Team_Red", new Color(0.88f, 0.18f, 0.16f));
            Material jungleMat = MakeMaterial("Jungle_Green", new Color(0.12f, 0.34f, 0.18f));
            Material neutralMat = MakeMaterial("Neutral_Stone", new Color(0.32f, 0.34f, 0.36f));

            CreateBlock("Arena Ground", new Vector3(0f, -0.6f, 0f),
                new Vector3(86f, 1f, 64f), groundMat);

            // Three clear lanes running between the two team bases.
            CreateBlock("Top Lane", new Vector3(0f, 0.02f, 21f),
                new Vector3(76f, 0.12f, 6f), laneMat);
            CreateBlock("Mid Lane", new Vector3(0f, 0.025f, 0f),
                new Vector3(76f, 0.14f, 6f), laneMat);
            CreateBlock("Bottom Lane", new Vector3(0f, 0.02f, -21f),
                new Vector3(76f, 0.12f, 6f), laneMat);

            // Bases and spawn platforms.
            CreateBlock("Blue Base Platform", new Vector3(-37f, 0.1f, 0f),
                new Vector3(9f, 0.45f, 30f), blueMat);
            CreateBlock("Red Base Platform", new Vector3(37f, 0.1f, 0f),
                new Vector3(9f, 0.45f, 30f), redMat);
            CreateTower("Blue Core", new Vector3(-39f, 1.5f, 0f), blueMat, 1.8f);
            CreateTower("Red Core", new Vector3(39f, 1.5f, 0f), redMat, 1.8f);

            float[] laneZ = { 21f, 0f, -21f };
            foreach (float z in laneZ)
            {
                CreateTower("Blue Outer Tower", new Vector3(-20f, 1.2f, z), blueMat, 1.1f);
                CreateTower("Red Outer Tower", new Vector3(20f, 1.2f, z), redMat, 1.1f);
            }

            // Jungle clearing markers between lanes. These are visual blockout pieces.
            Vector3[] jungleSpots =
            {
                new Vector3(-13f, 0.05f, 11f), new Vector3(0f, 0.05f, 11f),
                new Vector3(13f, 0.05f, 11f), new Vector3(-13f, 0.05f, -11f),
                new Vector3(0f, 0.05f, -11f), new Vector3(13f, 0.05f, -11f)
            };
            for (int i = 0; i < jungleSpots.Length; i++)
                CreateBlock("Jungle Clearing " + (i + 1), jungleSpots[i],
                    new Vector3(7f, 0.12f, 5f), jungleMat);

            CreateTrees(jungleMat, neutralMat);

            // The first controllable hero.
            GameObject hero = GameObject.CreatePrimitive(PrimitiveType.Capsule);
            hero.name = "Blue Hero - Starter";
            hero.transform.position = new Vector3(-29f, 1f, 0f);
            hero.GetComponent<Renderer>().sharedMaterial = blueMat;
            Object.DestroyImmediate(hero.GetComponent<CapsuleCollider>());

            CharacterController characterController = hero.AddComponent<CharacterController>();
            characterController.height = 2f;
            characterController.radius = 0.48f;
            characterController.center = new Vector3(0f, 0f, 0f);
            characterController.stepOffset = 0.3f;

            hero.AddComponent<HeroMotor>();
            hero.AddComponent<HeroKeyboardInput>();
            hero.AddComponent<Health>();

            // Camera follows the hero from an isometric angle.
            GameObject cameraObject = new GameObject("Main Camera");
            cameraObject.tag = "MainCamera";
            Camera camera = cameraObject.AddComponent<Camera>();
            camera.fieldOfView = 48f;
            camera.nearClipPlane = 0.1f;
            camera.farClipPlane = 250f;
            cameraObject.AddComponent<AudioListener>();
            TopDownCameraFollow follow = cameraObject.AddComponent<TopDownCameraFollow>();
            follow.SetTarget(hero.transform);
            cameraObject.transform.position = hero.transform.position + new Vector3(0f, 25f, -21f);
            cameraObject.transform.LookAt(hero.transform.position);

            GameObject lightObject = new GameObject("Directional Light");
            Light sun = lightObject.AddComponent<Light>();
            sun.type = LightType.Directional;
            sun.intensity = 1.15f;
            lightObject.transform.rotation = Quaternion.Euler(50f, -30f, 0f);

            // A scene label helps identify the current milestone in the Hierarchy.
            GameObject info = new GameObject("START HERE - WASD to move");
            info.transform.position = Vector3.zero;

            EditorSceneManager.MarkSceneDirty(scene);
            EditorSceneManager.SaveScene(scene, ScenePath);
            AssetDatabase.SaveAssets();
            AssetDatabase.Refresh();

            Selection.activeGameObject = hero;
            EditorUtility.DisplayDialog(
                "Starter Arena Created",
                "The 3D greybox arena has been created and saved. Press Play, then use WASD or the arrow keys to move the blue hero.",
                "OK");
        }

        private static Material MakeMaterial(string name, Color color)
        {
            string path = MaterialsFolder + "/" + name + ".mat";
            Material material = AssetDatabase.LoadAssetAtPath<Material>(path);

            if (material == null)
            {
                Shader shader = Shader.Find("Universal Render Pipeline/Lit");
                if (shader == null) shader = Shader.Find("Standard");
                if (shader == null) shader = Shader.Find("Unlit/Color");

                material = new Material(shader);
                material.name = name;
                AssetDatabase.CreateAsset(material, path);
            }

            material.color = color;
            EditorUtility.SetDirty(material);
            return material;
        }

        private static GameObject CreateBlock(string name, Vector3 position,
            Vector3 scale, Material material)
        {
            GameObject block = GameObject.CreatePrimitive(PrimitiveType.Cube);
            block.name = name;
            block.transform.position = position;
            block.transform.localScale = scale;
            block.GetComponent<Renderer>().sharedMaterial = material;
            return block;
        }

        private static void CreateTower(string name, Vector3 position,
            Material material, float scale)
        {
            GameObject tower = GameObject.CreatePrimitive(PrimitiveType.Cylinder);
            tower.name = name;
            tower.transform.position = position;
            tower.transform.localScale = new Vector3(scale, 1.5f * scale, scale);
            tower.GetComponent<Renderer>().sharedMaterial = material;

            GameObject crown = GameObject.CreatePrimitive(PrimitiveType.Sphere);
            crown.name = name + " Beacon";
            crown.transform.SetParent(tower.transform, false);
            crown.transform.localPosition = new Vector3(0f, 1.25f, 0f);
            crown.transform.localScale = new Vector3(0.55f, 0.55f, 0.55f);
            crown.GetComponent<Renderer>().sharedMaterial = material;
            Object.DestroyImmediate(crown.GetComponent<SphereCollider>());
        }

        private static void CreateTrees(Material leafMaterial, Material trunkMaterial)
        {
            Vector3[] positions =
            {
                new Vector3(-8f, 0f, 14f), new Vector3(8f, 0f, 14f),
                new Vector3(-8f, 0f, -14f), new Vector3(8f, 0f, -14f),
                new Vector3(0f, 0f, 14f), new Vector3(0f, 0f, -14f)
            };

            for (int i = 0; i < positions.Length; i++)
            {
                GameObject trunk = GameObject.CreatePrimitive(PrimitiveType.Cylinder);
                trunk.name = "Jungle Tree Trunk " + (i + 1);
                trunk.transform.position = positions[i] + new Vector3(0f, 1.1f, 0f);
                trunk.transform.localScale = new Vector3(0.55f, 1.1f, 0.55f);
                trunk.GetComponent<Renderer>().sharedMaterial = trunkMaterial;

                GameObject leaves = GameObject.CreatePrimitive(PrimitiveType.Sphere);
                leaves.name = "Jungle Tree Canopy " + (i + 1);
                leaves.transform.position = positions[i] + new Vector3(0f, 2.7f, 0f);
                leaves.transform.localScale = new Vector3(2.4f, 2.1f, 2.4f);
                leaves.GetComponent<Renderer>().sharedMaterial = leafMaterial;
            }
        }
    }
}
