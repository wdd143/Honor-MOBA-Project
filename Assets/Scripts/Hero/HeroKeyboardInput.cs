using UnityEngine;

namespace HonorMoba.Hero
{
    /// <summary>
    /// Starter keyboard input. Uses Unity's legacy Input Manager:
    /// WASD or arrow keys move the hero.
    /// </summary>
    [RequireComponent(typeof(HeroMotor))]
    public sealed class HeroKeyboardInput : MonoBehaviour
    {
        private HeroMotor motor;

        private void Awake()
        {
            motor = GetComponent<HeroMotor>();
        }

        private void Update()
        {
            float horizontal = 0f;
            float vertical = 0f;

            if (Input.GetKey(KeyCode.A) || Input.GetKey(KeyCode.LeftArrow)) horizontal -= 1f;
            if (Input.GetKey(KeyCode.D) || Input.GetKey(KeyCode.RightArrow)) horizontal += 1f;
            if (Input.GetKey(KeyCode.S) || Input.GetKey(KeyCode.DownArrow)) vertical -= 1f;
            if (Input.GetKey(KeyCode.W) || Input.GetKey(KeyCode.UpArrow)) vertical += 1f;

            motor.Move(Vector2.ClampMagnitude(new Vector2(horizontal, vertical), 1f));
        }
    }
}
