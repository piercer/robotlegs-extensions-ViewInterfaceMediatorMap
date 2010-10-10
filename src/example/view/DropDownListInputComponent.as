package example.view
{
    import flash.events.Event;

    import org.osflash.signals.ISignal;
    import org.osflash.signals.Signal;

    import spark.components.DropDownList;
    import spark.components.supportClasses.SkinnableComponent;

    public class DropDownListInputComponent extends SkinnableComponent implements INumberEntry
    {

        [SkinPart(required="true")]
        public var numberList:DropDownList;

        private var _numberEntered:Signal;

        public function DropDownListInputComponent()
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
                case numberList:
                    numberList.addEventListener(Event.CHANGE,onNumberSliderChange);
                    break;
            }
        }

        override protected function partRemoved(partName:String, instance:Object):void
        {
            switch( instance )
            {
                case numberList:
                    numberList.removeEventListener(Event.CHANGE,onNumberSliderChange);
                    break;
            }
            super.partAdded(partName, instance);
        }

        private function onNumberSliderChange(event:Event):void
        {
            _numberEntered.dispatch(numberList.selectedItem);
        }
    }

}
