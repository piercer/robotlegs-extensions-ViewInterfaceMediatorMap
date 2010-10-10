package example.events
{
    import flash.events.Event;

    public class NumberEnteredEvent extends Event
    {

        public static const NUMBER_ENTERED:String = "numberEntered";

        private var _number:Number;

        public function NumberEnteredEvent(number:Number)
        {
            super(NUMBER_ENTERED);
            _number = number;
        }

        public function get number():Number
        {
            return _number;
        }
    }
}
