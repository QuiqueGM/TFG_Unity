using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.UI;
using Cinemachine;

namespace UOC.TFG.TechnicalDemo
{
    public class DemoSceneAController : DemoScenes
    {
        private const int NUMBER_OF_ANIMATIONS = 5;

        [SerializeField] private InputActionAsset playerControls;
        [SerializeField] private CinemachineFreeLook cinemachine;

        [SerializeField] private Animator animator;
        [SerializeField] private Renderer mesh;
        [SerializeField] private List<Material> skins;
        [SerializeField] private Button nextAnimation;
        [SerializeField] private Button previousAnimation;
        [SerializeField] private Button nextSkin;
        [SerializeField] private Button previousSkin;
        [SerializeField] private CanvasManager canvasManager;

        private Dictionary<InputAction, Action<InputAction.CallbackContext>> _actions;
        private int _animation = 0;
        private int _skin = 0;
        private bool _menuPauseState;

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

            nextAnimation.onClick.AddListener(SetNextAnimation);
            previousAnimation.onClick.AddListener(SetPrevAnimation);
            nextSkin.onClick.AddListener(SetNextSkin);
            previousSkin.onClick.AddListener(SetPrevSkin);
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

        private void ShowMenuPause(InputAction.CallbackContext context)
        {
            if (context.ReadValueAsButton())
            {
                ShowMenuPause();
            }
        }

        #endregion

        public void SetNextAnimation()
        {
            _animation = _animation == NUMBER_OF_ANIMATIONS - 1 ? 0 : ++_animation;
            SetAnimation();
        }

        public void SetPrevAnimation()
        {
            _animation = _animation == 0 ? NUMBER_OF_ANIMATIONS - 1 : --_animation;
            SetAnimation();
        }

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

        private void SetAnimation()
        {
            if (_menuPauseState) return;

            animator.SetFloat(StringsData.ANIMATIONS, _animation);
        }

        private void SetSkin()
        {
            if (_menuPauseState) return;

            mesh.material = skins[_skin];
        }

        public override void ShowMenuPause()
        {
            cinemachine.enabled = _menuPauseState;
            animator.enabled = _menuPauseState;
            nextAnimation.interactable = _menuPauseState;
            previousAnimation.interactable = _menuPauseState;
            nextSkin.interactable = _menuPauseState;
            previousSkin.interactable = _menuPauseState;
            _menuPauseState = !_menuPauseState;
            canvasManager.ShowMenuPause(_menuPauseState);
        }
    }
}