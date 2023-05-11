using UnityEngine;

namespace UOC.TFG.TechnicalDemo
{
    public class CanvasManager : MonoBehaviour
    {
        [SerializeField] private GameObject menuHelp;
        [SerializeField] private GameObject menuPause;

        void Awake()
        {
            menuPause.SetActive(false);
            menuHelp.SetActive(false);
        }

        public void ShowMenuPause(bool state)
        {
            menuPause.SetActive(state);
            menuHelp.SetActive(false);
        }

        public void ShowMenuHelp()
        {
            menuHelp.SetActive(true);
            menuPause.SetActive(false);
        }
    }
}
