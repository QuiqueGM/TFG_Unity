using UnityEngine;
using UnityEngine.UI;

namespace UOC.TFG.TechnicalDemo
{
    public class MenuPause : MonoBehaviour
    {
        [SerializeField] private Button resume;
        [SerializeField] private Button howTo;
        [SerializeField] private Button mainMenu;

        private DemoSceneAController _demoSceneAController;

        void Awake()
        {
            resume.onClick.AddListener(Resume);
            howTo.onClick.AddListener(HowTo);
            mainMenu.onClick.AddListener(MainMenu);

            _demoSceneAController = (DemoSceneAController)FindObjectOfType(typeof(DemoSceneAController));
        }

        private void Resume()
        {
            _demoSceneAController.ShowMenuPause();
        }

        private void HowTo()
        {
            // Show how does it works this demo
        }

        private void MainMenu()
        {
            // Return to main menu
        }
    }
}
