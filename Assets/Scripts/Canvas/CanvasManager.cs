using UnityEngine;

namespace UOC.TFG.TechnicalDemo
{
    public class CanvasManager : MonoBehaviour
    {
        [SerializeField] private GameObject canvasMenuScene;
        [SerializeField] private GameObject menuHelp;
        [SerializeField] private GameObject menuPause;
        [SerializeField] private GameObject menuEnd;

        void Awake()
        {
            menuPause.SetActive(false);
            menuHelp.SetActive(false);

            if (menuEnd != null)
                menuEnd.SetActive(false);

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

        public void ShowMenuEnd()
        {
            menuEnd.SetActive(true);
            canvasMenuScene.SetActive(false);
        }
    }
}
