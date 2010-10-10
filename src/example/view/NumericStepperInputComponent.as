package example.view
{
    import flash.events.Event;

    import org.osflash.signals.ISignal;

    import org.osflash.signals.Signal;

    import spark.components.NumericStepper;
    import spark.components.supportClasses.SkinnableComponent;

    public class NumericStepperInputComponent extends SkinnableComponent implements INumberEntry
    {

        [SkinPart(required="true")]
        public var numberStepper:NumericStepper;

        private var _numberEntered:Signal;

        public function NumericStepperInputComponent()
        {
            _numberEntered = new Signal(Number);
        }

        public function get numberEntered():ISignal
        {
            return _numberEntered;
        }

        private function onNumberStepperChange(event:Event):void
        {
            _numberEntered.dispatch(numberStepper.value);
        }

        override protected function partAdded(partName:String, instance:Object):void
        {
            super.partAdded(partName, instance);
            switch ( instance )
            {
                case numberStepper:
                    numberStepper.addEventListener(Event.CHANGE,onNumberStepperChange);
                    break;
            }
        }


        override protected function partRemoved(partName:String, instance:Object):void
        {
            switch ( instance )
            {
                case numberStepper:
                    numberStepper.addEventListener(Event.CHANGE,onNumberStepperChange);
                    break;
            }
            super.partRemoved(partName, instance);
        }
    }

}
