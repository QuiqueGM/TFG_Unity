using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.UI;
using Cinemachine;

namespace UOC.TFG.TechnicalDemo
{
    public class DemoSceneBController : MonoBehaviour
    {
        [SerializeField] private InputActionAsset playerControls;
        [SerializeField] private CinemachineFreeLook cinemachine;

        [SerializeField] private Animator animator;
        [SerializeField] private Rigidbody rigidbody;
        [SerializeField] private Renderer mesh;
        [SerializeField] private List<Material> skins;
        [SerializeField] private Button nextSkin;
        [SerializeField] private Button previousSkin;
        [SerializeField] private GameObject menuPause;
        [Space(10)]
        [SerializeField] private float speed = 200.0f;

        private Dictionary<InputAction, Action<InputAction.CallbackContext>> _actions;
        private int _skin = 0;
        private Vector3 _targetRotation;
        private Vector3 _direction;
        private bool _menuPauseState;

        private void Awake()
        {
            var gamePlayMap = playerControls.FindActionMap(StringsData.DEMOSCENE_B);

            _actions = new Dictionary<InputAction, Action<InputAction.CallbackContext>>
            {
                { gamePlayMap.FindAction(StringsData.NEXT_SKIN), SetNextSkin },
                { gamePlayMap.FindAction(StringsData.PREV_SKIN), SetPrevSkin },
                { gamePlayMap.FindAction(StringsData.LOCOMOTION), Locomotion }
                //{ gamePlayMap.FindAction(StringsData.MENU_PAUSE), ShowMenuPause }
            };

            foreach (var action in _actions)
            {
                action.Key.performed += action.Value;
                action.Key.canceled += action.Value;
            }

            //nextSkin.onClick.AddListener(SetNextSkin);
            //previousSkin.onClick.AddListener(SetPrevSkin);

            //menuPause.SetActive(_menuPauseState);
        }

        private void OnEnable()
        {
            foreach (var action in _actions)
                action.Key.Enable();
        }

        private void OnDisable()
        {
            foreach (var action in _actions)
                action.Key.Disable();
        }

        void FixedUpdate()
        {
            float magnitude = _direction.magnitude;

            if (magnitude >= 0.01f)
            {
                _targetRotation = Quaternion.LookRotation(_direction).eulerAngles;
                animator.SetFloat(StringsData.LOCOMOTION, magnitude);
            }
            else
            {
                animator.SetFloat(StringsData.LOCOMOTION, 0);
            }

            rigidbody.rotation = Quaternion.Slerp(transform.rotation, Quaternion.Euler(_targetRotation), Mathf.Infinity);
            rigidbody.velocity = _direction * speed * Time.deltaTime;
        }

        #region CALLBACKS

        private void SetNextSkin(InputAction.CallbackContext context)
        {
            if (context.ReadValueAsButton())
            {
                SetNextSkin();
            }
        }

        private void SetPrevSkin(InputAction.CallbackContext context)
        {
            if (context.ReadValueAsButton())
            {
                SetPrevSkin();
            }
        }

        private void Locomotion(InputAction.CallbackContext context)
        {
            var move = context.ReadValue<Vector2>();
            _direction = new(move.x, 0, move.y);
        }

        //private void ShowMenuPause(InputAction.CallbackContext context)
        //{
        //    if (context.ReadValueAsButton())
        //    {
        //        ShowMenuPause();
        //    }
        //}

        #endregion

        public void SetNextSkin()
        {
            _skin = _skin == skins.Count - 1 ? 0 : ++_skin;
            SetSkin();
        }

        public void SetPrevSkin()
        {
            _skin = _skin == 0 ? skins.Count - 1 : --_skin;
            SetSkin();
        }

        private void SetSkin()
        {
            //if (_menuPauseState) return;

            mesh.material = skins[_skin];
        }

        //public void ShowMenuPause()
        //{
        //    cinemachine.enabled = _menuPauseState;
        //    animator.enabled = _menuPauseState;
        //    _menuPauseState = !_menuPauseState;
        //    menuPause.SetActive(_menuPauseState);
        //}

        private void OnTriggerEnter(Collider other)
        {
            if (other.CompareTag(StringsData.TOMATO))
            {
                // Initialize TOMATO sequence
            }
        }
    }
}