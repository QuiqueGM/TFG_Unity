using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.UI;

namespace UOC.TFG.TechnicalDemo
{
    public class MenuHelp : MonoBehaviour
    {
        [SerializeField] private Button close;

        public void OnEnable()
        {
            EventSystem.current.SetSelectedGameObject(close.gameObject);
        }
    }
}
