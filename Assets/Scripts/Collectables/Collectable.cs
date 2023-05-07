using UnityEngine;

namespace UOC.TFG.TechnicalDemo
{
    public class Collectable : MonoBehaviour, ICollectable
    {
        public virtual void OnCollectable()
        {
            Destroy(gameObject);
        }
    }
}
