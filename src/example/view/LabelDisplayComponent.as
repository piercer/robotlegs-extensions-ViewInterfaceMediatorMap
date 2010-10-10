package example.view
{

    import org.osflash.signals.ISignal;

    import spark.components.Label;
    import spark.components.supportClasses.SkinnableComponent;

    public class LabelDisplayComponent extends SkinnableComponent implements INumberDisplay
    {

        [SkinPart(required="true")]
        public var numberDisplay:Label;

        public function LabelDisplayComponent()
        {
        }

        public function set numberUpdated(value:ISignal):void
        {
            value.add(onNumberUpdated)
        }

        private function onNumberUpdated(number:Number):void
        {
            numberDisplay.text = number.toString();
        }

    }

}
