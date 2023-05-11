using UnityEngine;
using UnityEngine.UI;
using UnityEngine.EventSystems;

namespace UOC.TFG.TechnicalDemo
{
    public class MenuPause : MonoBehaviour
    {
        [SerializeField] private Button resume;
        [SerializeField] private Button help;
        [SerializeField] private Button mainMenu;

        private DemoScenes _demoScene;
        private bool _help = false;

        void Awake()
        {
            resume.onClick.AddListener(Resume);
            mainMenu.onClick.AddListener(MainMenu);
        }

        private void Start()
        {
            _demoScene = (DemoScenes)FindObjectOfType(typeof(DemoScenes));
        }

        public void OnEnable()
        {
            EventSystem.current.SetSelectedGameObject(resume.gameObject);
        }

        private void Resume()
        {
            _demoScene.ShowMenuPause();
        }

        private void MainMenu()
        {
            UnityEngine.SceneManagement.SceneManager.LoadScene(0);
        }
    }
}
