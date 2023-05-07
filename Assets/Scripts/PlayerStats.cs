using System;
using UnityEngine;

namespace UOC.TFG.TechnicalDemo
{
    public class PlayerStats : MonoBehaviour
    {
        public Action<int> TomatoEvent;
        public Action<int> CoinEvent;

        public static PlayerStats instance;

        private int _tomatos;
        private int _coins;

        private void Awake()
        {
            instance = this;
            ResetStats();
        }

        public void ResetStats()
        {
            _tomatos = 0;
            _coins = 0;
        }

        public void ManageTomatos()
        {
            _tomatos++;
            TomatoEvent?.Invoke(_tomatos);
        }

        public void ManageCoins()
        {
            _coins++;
            CoinEvent?.Invoke(_coins);
        }
    }
}