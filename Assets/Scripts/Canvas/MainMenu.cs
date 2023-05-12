using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.UI;

namespace UOC.TFG.TechnicalDemo
{
    public class MainMenu : MonoBehaviour
    {
        private readonly string DEMOSCENE_A = "DemoScene_A";
        private readonly string DEMOSCENE_B = "DemoScene_B";

        [SerializeField] private Button demoSceneA;
        [SerializeField] private Button demoSceneB;
        [SerializeField] private Button credits;
        [SerializeField] private Button quit;

        void Awake()
        {
            demoSceneA.onClick.AddListener(DemoSceneA);
            demoSceneB.onClick.AddListener(DemoSceneB);
            credits.onClick.AddListener(Credits);
            quit.onClick.AddListener(Quit);
        }

        private void DemoSceneA()
        {
            SceneManager.LoadScene(DEMOSCENE_A);
        }

        private void DemoSceneB()
        {
            SceneManager.LoadScene(DEMOSCENE_B);
        }

        private void Credits()
        {
        }

        private void Quit()
        {
            Application.Quit();
        }
    }
}
