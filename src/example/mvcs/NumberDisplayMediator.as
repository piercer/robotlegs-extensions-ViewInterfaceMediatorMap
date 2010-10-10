package example.mvcs
{
    import example.signals.NumberUpdatedSignal;
    import example.view.INumberDisplay;

    import org.robotlegs.mvcs.Mediator;

    public class NumberDisplayMediator extends Mediator
    {

        [Inject]
        public var view:INumberDisplay;

        [Inject]
        public var numberUpdated:NumberUpdatedSignal;

        public function NumberDisplayMediator()
        {
        }

        [PostConstruct]
        public function init():void
        {
            view.numberUpdated = numberUpdated;
        }
    }
}
