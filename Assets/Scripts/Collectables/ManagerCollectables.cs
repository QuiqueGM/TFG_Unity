using UnityEngine;

namespace UOC.TFG.TechnicalDemo
{
    public class ManagerCollectables : MonoBehaviour
    {
        public CanvasManager canvasManager;
        public DemoSceneBController demoSceneBController;
        void Awake()
        {
            PlayerStats.instance.Coins = GetComponentsInChildren<CollectableCoin>().Length;
            PlayerStats.instance.Tomatos = GetComponentsInChildren<CollectableTomato>().Length;

            demoSceneBController.OnChangeCoins(0);
            demoSceneBController.OnChangeTomatos(0);
        }

        private void Update()
        {
            if (transform.childCount == 0)
                canvasManager.ShowMenuEnd();
        }
    }
}