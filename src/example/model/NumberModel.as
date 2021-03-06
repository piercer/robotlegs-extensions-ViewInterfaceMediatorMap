package example.model
{
    import example.signals.NumberUpdatedSignal;

    public class NumberModel
    {

        [Inject]
        public var numberUpdated:NumberUpdatedSignal;

        private var _currentNumber:Number;

        public function NumberModel()
        {

        }

        public function set currentNumber(value:Number):void
        {
            if ( _currentNumber == value ) return;

            _currentNumber = value;
            numberUpdated.dispatch(_currentNumber);
        }
    }
}
