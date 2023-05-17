using UnityEngine;
using UnityEngine.UI;
using UnityEngine.EventSystems;
using UnityEngine.SceneManagement;

namespace UOC.TFG.TechnicalDemo
{
    public class MenuEnd : MonoBehaviour
    {
        [SerializeField] private Button replay;
        [SerializeField] private Button mainMenu;

        void Awake()
        {
            replay.onClick.AddListener(Replay);
            mainMenu.onClick.AddListener(MainMenu);
        }

        public void OnEnable()
        {
            EventSystem.current.SetSelectedGameObject(replay.gameObject);
        }

        private void Replay()
        {
            SceneManager.LoadScene(StringsData.DEMOSCENE_B);
        }

        private void MainMenu()
        {
            SceneManager.LoadScene(0);
        }
    }
}
