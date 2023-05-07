using UnityEngine;

namespace UOC.TFG.TechnicalDemo
{
    [RequireComponent(typeof(Rigidbody))]
    public class DragonController : MonoBehaviour
    {
        public Animator animator;
        [SerializeField] private Renderer mesh;
        [SerializeField] private float speed = 200.0f;

        private Rigidbody _rigidbody;
        private Vector3 _targetRotation;
        private Vector3 _direction;
        private float _magnitude;

        private void Awake()
        {
            _rigidbody = GetComponent<Rigidbody>();
        }

        public void Move(Vector3 _movement)
        {
            _direction = new(_movement.x, 0, _movement.y);
            _magnitude = _direction.magnitude;

            if (_magnitude >= 0.01f)
            {
                _targetRotation = Quaternion.LookRotation(_direction).eulerAngles;
                animator.SetFloat(StringsData.LOCOMOTION, _magnitude);
            }
            else
            {
                animator.SetFloat(StringsData.LOCOMOTION, 0);
            }

            _rigidbody.rotation = Quaternion.Slerp(transform.rotation, Quaternion.Euler(_targetRotation), Mathf.Infinity);
            _rigidbody.velocity = _direction * speed * Time.deltaTime;
        }

        public void ChangeSkin(Material skin)
        {
            mesh.material = skin;
        }

        private void OnTriggerEnter(Collider other)
        {
            if (other.CompareTag(StringsData.COLLECTABLE))
            {
                other.GetComponent<ICollectable>().OnCollectable();
            }
        }
    }
}