package example.view
{
    import org.osflash.signals.ISignal;

    public interface INumberDisplay
    {
        function set numberUpdated(value:ISignal):void;
    }

}
