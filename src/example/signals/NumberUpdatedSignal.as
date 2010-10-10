package example.signals
{
    import org.osflash.signals.Signal;

    public class NumberUpdatedSignal extends Signal
    {
        public function NumberUpdatedSignal()
        {
            super(Number);
        }
    }
}
