using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.UI;
using Cinemachine;
using TMPro;

namespace UOC.TFG.TechnicalDemo
{
    public class DemoSceneBController : DemoScenes
    {
        [Header("Main properties")]
        [SerializeField] private InputActionAsset playerControls;
        [SerializeField] private CinemachineVirtualCamera cinemachine;
        [SerializeField] private DragonController dragonController;
        [Header("Skins")]
        [SerializeField] private List<Material> skins;
        [Header("UI")]
        [SerializeField] private Button nextSkin;
        [SerializeField] private Button previousSkin;
        [SerializeField] private TMP_Text TXT_coins;
        [SerializeField] private TMP_Text TXT_tomatos;
        [SerializeField] private GameObject menuPause;

        private Dictionary<InputAction, Action<InputAction.CallbackContext>> _actions;
        private Vector3 _direction;
        private int _skin = 0;
        private bool _menuPauseState;

        private void Awake()
        {
            var gamePlayMap = playerControls.FindActionMap(StringsData.DEMOSCENE_B);

            _actions = new Dictionary<InputAction, Action<InputAction.CallbackContext>>
            {
                { gamePlayMap.FindAction(StringsData.NEXT_SKIN), SetNextSkin },
                { gamePlayMap.FindAction(StringsData.PREV_SKIN), SetPrevSkin },
                { gamePlayMap.FindAction(StringsData.LOCOMOTION), Locomotion },
                { gamePlayMap.FindAction(StringsData.MENU_PAUSE), ShowMenuPause }
            };

            foreach (var action in _actions)
            {
                action.Key.performed += action.Value;
                action.Key.canceled += action.Value;
            }

            nextSkin.onClick.AddListener(SetNextSkin);
            previousSkin.onClick.AddListener(SetPrevSkin);

            PlayerStats.instance.CoinEvent += OnChangeCoins;
            PlayerStats.instance.TomatoEvent += OnChangeTomatos;



            menuPause.SetActive(_menuPauseState);
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

        private void OnDestroy()
        {
            PlayerStats.instance.CoinEvent -= OnChangeCoins;
            PlayerStats.instance.TomatoEvent -= OnChangeTomatos;
        }

        void FixedUpdate()
        {
            dragonController.Move(_direction);
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
            _direction = context.ReadValue<Vector2>();
        }

        public void OnChangeCoins(int coins)
        {
            TXT_coins.text = string.Format($"Coins: {coins} / {PlayerStats.instance.Coins}");
        }

        public void OnChangeTomatos(int tomatos)
        {
            TXT_tomatos.text = string.Format($"Tomatos: {tomatos} / {PlayerStats.instance.Tomatos}");
        }

        private void ShowMenuPause(InputAction.CallbackContext context)
        {
            if (context.ReadValueAsButton())
            {
                ShowMenuPause();
            }
        }

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
            if (_menuPauseState) return;

            dragonController.ChangeSkin(skins[_skin]);
        }

        public override void ShowMenuPause()
        {
            cinemachine.enabled = _menuPauseState;
            dragonController.PauseDragonController(_menuPauseState);
            _menuPauseState = !_menuPauseState;
            menuPause.SetActive(_menuPauseState);
        }
    }
}