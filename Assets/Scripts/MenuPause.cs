using UnityEngine;
using UnityEngine.UI;

namespace UOC.TFG.TechnicalDemo
{
    public class MenuPause : MonoBehaviour
    {
        [SerializeField] private Button resume;
        [SerializeField] private Button help;
        [SerializeField] private Button mainMenu;

        private DemoScenes _demoScene;

        void Awake()
        {
            resume.onClick.AddListener(Resume);
            help.onClick.AddListener(ShowHelp);
            mainMenu.onClick.AddListener(MainMenu);
        }

        private void Start()
        {
            _demoScene = (DemoScenes)FindObjectOfType(typeof(DemoScenes));
        }

        private void Resume()
        {
            _demoScene.ShowMenuPause();
        }

        private void ShowHelp()
        {
            _demoScene.ShowHelp();
        }

        private void MainMenu()
        {
            UnityEngine.SceneManagement.SceneManager.LoadScene(0);
        }
    }
}
