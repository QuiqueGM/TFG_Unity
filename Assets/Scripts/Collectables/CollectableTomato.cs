namespace UOC.TFG.TechnicalDemo
{
    public class CollectableTomato : Collectable
    {
        public override void OnCollectable()
        {
            PlayerStats.instance.ManageTomatos();
            base.OnCollectable();
        }
    }
}
