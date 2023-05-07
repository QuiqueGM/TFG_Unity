namespace UOC.TFG.TechnicalDemo
{
    public class CollectableCoin : Collectable
    {
        public override void OnCollectable()
        {
            PlayerStats.instance.ManageCoins();
            base.OnCollectable();
        }
    }
}
