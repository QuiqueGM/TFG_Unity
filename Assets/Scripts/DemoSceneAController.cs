using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;

namespace UOC.TFG.TechnicalDemo
{
    public class DemoSceneAController : MonoBehaviour
    {
        private const int NUMBER_OF_ANIMATIONS = 4;

        [SerializeField] private InputActionAsset playerControls;
        [SerializeField] private Animator animator;
        [SerializeField] private Renderer mesh;
        [SerializeField] private List<Material> skins;

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

        public void SetNextAnimation(InputAction.CallbackContext context)
        {
            if (context.ReadValueAsButton())
            {
                _animation = _animation == NUMBER_OF_ANIMATIONS ? 0 : ++_animation;
                SetAnimation();
            }
        }

        public void SetPrevAnimation(InputAction.CallbackContext context)
        {
            if (context.ReadValueAsButton())
            {
                _animation = _animation == 0 ? NUMBER_OF_ANIMATIONS : --_animation;
                SetAnimation();
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

        private void SetAnimation()
        {
            animator.SetFloat(StringsData.ANIMATIONS, _animation);
        }

        private void SetMaterial()
        {
            mesh.material = skins[_skin];
        }

        #endregion
    }
}
