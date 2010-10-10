package example.mvcs
{
    import example.events.NumberEnteredEvent;
    import example.view.INumberEntry;

    import org.robotlegs.mvcs.Mediator;

    public class NumberEntryMediator extends Mediator
    {

        [Inject]
        public var view:INumberEntry;

        public function NumberEntryMediator()
        {
        }

        [PostConstruct]
        public function init():void
        {
            view.numberEntered.add(onViewNumberEntered)
        }

        private function onViewNumberEntered(number:Number):void
        {
            dispatch(new NumberEnteredEvent(number));
        }
    }
}
