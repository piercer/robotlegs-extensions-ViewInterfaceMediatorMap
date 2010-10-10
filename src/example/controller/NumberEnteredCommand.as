package example.controller
{
    import example.events.NumberEnteredEvent;
    import example.model.NumberModel;

    public class NumberEnteredCommand
    {

        [Inject]
        public var event:NumberEnteredEvent;

        [Inject]
        public var numberModel:NumberModel;

        public function execute():void
        {
            numberModel.currentNumber = event.number;
        }
    }

}
