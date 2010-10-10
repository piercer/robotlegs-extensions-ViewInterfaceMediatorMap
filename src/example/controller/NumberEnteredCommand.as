package example.controller
{
    import example.events.NumberEnteredEvent;
    import example.model.NumberController;

    public class NumberEnteredCommand
    {

        [Inject]
        public var event:NumberEnteredEvent;

        [Inject]
        public var numberModel:NumberController;

        public function execute()
        {
            numberModel.currentNumber = event.number;
        }
    }

}
