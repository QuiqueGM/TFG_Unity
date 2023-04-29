using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.UI;

namespace UOC.TFG.TechnicalDemo
{
    public class DemoSceneAController : MonoBehaviour
    {
        private const int NUMBER_OF_ANIMATIONS = 4;

        [SerializeField] private InputActionAsset playerControls;
        [SerializeField] private Animator animator;
        [SerializeField] private Renderer mesh;
        [SerializeField] private List<Material> skins;
        public Button test;
        public Button test2;

        private Dictionary<InputAction, Action<InputAction.CallbackContext>> _actions;
        private int _animation = 0;
        private int _skin = 0;

        private void Awake()
        {
            var gamePlayMap = playerControls.FindActionMap(StringsData.DEMOSCENE_A);

            _actions = new Dictionary<InputAction, Action<InputAction.CallbackContext>>
            {
                { gamePlayMap.FindAction(StringsData.NEXT_ANIM), SetNextAnimation },
                { gamePlayMap.FindAction(StringsData.PREV_ANIM), SetPrevAnimation },
                { gamePlayMap.FindAction(StringsData.NEXT_SKIN), SetNextSkin },
                { gamePlayMap.FindAction(StringsData.PREV_SKIN), SetPrevSkin },
                { gamePlayMap.FindAction(StringsData.MENU_PAUSE), ShowMenuPause }
            };

            foreach (var action in _actions)
            {
                action.Key.performed += action.Value;
                action.Key.canceled += action.Value;
            }

            test.onClick.AddListener(SetNextAnimation);
            test2.onClick.AddListener(SetPrevAnimation);
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

        #region CALLBACKS

        private void SetNextAnimation(InputAction.CallbackContext context)
        {
            if (context.ReadValueAsButton())
            {
                SetNextAnimation();
            }
        }

        private void SetPrevAnimation(InputAction.CallbackContext context)
        {
            if (context.ReadValueAsButton())
            {
                SetPrevAnimation();
            }
        }

        private void SetNextSkin(InputAction.CallbackContext context)
        {
            if (context.ReadValueAsButton())
            {
                _skin = _skin == skins.Count-1 ? 0 : ++_skin;
                SetMaterial();
            }
        }

        private void SetPrevSkin(InputAction.CallbackContext context)
        {
            if (context.ReadValueAsButton())
            {
                _skin = _skin == 0 ? skins.Count-1 : --_skin;
                SetMaterial();
            }
        }

        private void ShowMenuPause(InputAction.CallbackContext context)
        {
            if (context.ReadValueAsButton())
            {
                // Show Menu Pause screen
            }
        }

        public void SetNextAnimation()
        {
            _animation = _animation == NUMBER_OF_ANIMATIONS ? 0 : ++_animation;
            animator.SetFloat(StringsData.ANIMATIONS, _animation);
        }

        public void SetPrevAnimation()
        {
            _animation = _animation == 0 ? NUMBER_OF_ANIMATIONS : --_animation;
            animator.SetFloat(StringsData.ANIMATIONS, _animation);
        }


        private void SetMaterial()
        {
            mesh.material = skins[_skin];
        }

        #endregion
    }
}
