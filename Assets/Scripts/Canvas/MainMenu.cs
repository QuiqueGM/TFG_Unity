using UnityEngine;
using UnityEngine.EventSystems;
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
        [Space(5)]
        [SerializeField] private GameObject buttons;
        [SerializeField] private GameObject CNV_credits;


        void Awake()
        {
            demoSceneA.onClick.AddListener(DemoSceneA);
            demoSceneB.onClick.AddListener(DemoSceneB);
            credits.onClick.AddListener(Credits);
            quit.onClick.AddListener(Quit);

            buttons.SetActive(true);
            CNV_credits.SetActive(false);
        }

        public void OnEnable()
        {
            EventSystem.current.SetSelectedGameObject(demoSceneA.gameObject);
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
            buttons.SetActive(false);
            CNV_credits.SetActive(true);
        }

        private void Quit()
        {
            Application.Quit();
        }
    }
}
