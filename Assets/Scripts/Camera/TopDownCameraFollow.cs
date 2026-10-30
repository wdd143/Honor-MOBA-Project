using UnityEngine;

namespace HonorMoba.CameraSystem
{
    /// <summary>Isometric follow camera. Attach to the Main Camera.</summary>
    public sealed class TopDownCameraFollow : MonoBehaviour
    {
        [SerializeField] private Transform target;
        [SerializeField] private Vector3 offset = new Vector3(0f, 14f, -10f);
        [SerializeField, Min(0.01f)] private float smoothTime = 0.18f;
        [SerializeField] private bool lookAtTarget = true;

        private Vector3 followVelocity;

        public void SetTarget(Transform newTarget) => target = newTarget;

        private void LateUpdate()
        {
            if (target == null) return;

            Vector3 desiredPosition = target.position + offset;
            transform.position = Vector3.SmoothDamp(
                transform.position, desiredPosition, ref followVelocity, smoothTime);

            if (lookAtTarget)
                transform.rotation = Quaternion.LookRotation(
                    target.position - transform.position, Vector3.up);
        }
    }
}
