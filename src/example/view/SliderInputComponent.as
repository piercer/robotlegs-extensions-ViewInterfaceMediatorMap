package example.view
{

    import flash.events.Event;

    import org.osflash.signals.ISignal;

    import org.osflash.signals.Signal;

    import spark.components.HSlider;
    import spark.components.supportClasses.SkinnableComponent;

    public class SliderInputComponent extends SkinnableComponent implements INumberEntry
    {

        [SkinPart(required="true")]
        public var numberSlider:HSlider;

        private var _numberEntered:Signal;

        public function SliderInputComponent()
        {
            _numberEntered = new Signal(Number);
        }

        public function get numberEntered():ISignal
        {
            return _numberEntered;
        }

        override protected function partAdded(partName:String, instance:Object):void
        {
            super.partAdded(partName, instance);
            switch( instance )
            {
                case numberSlider:
                    numberSlider.addEventListener(Event.CHANGE,onNumberSliderChange);
                    break;
            }
        }

        override protected function partRemoved(partName:String, instance:Object):void
        {
            switch( instance )
            {
                case numberSlider:
                    numberSlider.removeEventListener(Event.CHANGE,onNumberSliderChange);
                    break;
            }
            super.partAdded(partName, instance);
        }

        private function onNumberSliderChange(event:Event):void
        {
            _numberEntered.dispatch(numberSlider.value);
        }
    }

}
