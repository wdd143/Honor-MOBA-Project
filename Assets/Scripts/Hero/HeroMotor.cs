using UnityEngine;

namespace HonorMoba.Hero
{
    /// <summary>
    /// Simple camera-relative movement for a MOBA hero.
    /// Add this component and a CharacterController to a hero root object.
    /// </summary>
    [RequireComponent(typeof(CharacterController))]
    public sealed class HeroMotor : MonoBehaviour
    {
        [SerializeField, Min(0.1f)] private float moveSpeed = 6f;
        [SerializeField, Min(1f)] private float rotationSpeed = 720f;
        [SerializeField] private Transform cameraTransform;
        [SerializeField] private float gravity = -20f;

        private CharacterController controller;
        private float verticalVelocity;

        private void Awake()
        {
            controller = GetComponent<CharacterController>();
            if (cameraTransform == null && Camera.main != null)
                cameraTransform = Camera.main.transform;
        }

        /// <summary>Call with a normalized 2D input direction, such as WASD or a joystick.</summary>
        public void Move(Vector2 input)
        {
            Vector3 forward = cameraTransform != null
                ? Vector3.ProjectOnPlane(cameraTransform.forward, Vector3.up).normalized
                : Vector3.forward;
            Vector3 right = cameraTransform != null
                ? Vector3.ProjectOnPlane(cameraTransform.right, Vector3.up).normalized
                : Vector3.right;

            Vector3 direction = Vector3.ClampMagnitude(
                right * input.x + forward * input.y, 1f);

            if (direction.sqrMagnitude > 0.001f)
            {
                Quaternion targetRotation = Quaternion.LookRotation(direction, Vector3.up);
                transform.rotation = Quaternion.RotateTowards(
                    transform.rotation, targetRotation, rotationSpeed * Time.deltaTime);
            }

            if (controller.isGrounded && verticalVelocity < 0f)
                verticalVelocity = -2f;

            verticalVelocity += gravity * Time.deltaTime;
            Vector3 velocity = direction * moveSpeed;
            velocity.y = verticalVelocity;
            controller.Move(velocity * Time.deltaTime);
        }
    }
}
