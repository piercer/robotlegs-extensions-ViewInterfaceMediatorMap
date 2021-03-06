package example.mvcs
{
    import example.controller.NumberEnteredCommand;
    import example.events.NumberEnteredEvent;
    import example.model.NumberModel;
    import example.signals.NumberUpdatedSignal;
    import example.view.INumberDisplay;
    import example.view.INumberEntry;

    import org.robotlegs.base.ViewInterfaceMediatorMap;
    import org.robotlegs.core.IMediatorMap;
    import org.robotlegs.mvcs.Context;

    public class InterfaceEnabledMediatorMapContextExample extends Context
    {

        public function InterfaceEnabledMediatorMapContextExample()
        {
        }

        //
        // Override the default mediator map with one that can map to interfaces
        //
        override protected function get mediatorMap():IMediatorMap
        {
            return _mediatorMap ||= new ViewInterfaceMediatorMap(contextView, createChildInjector(), reflector);
        }


        override public function startup():void
        {
            injector.mapSingleton(NumberModel);
            injector.mapSingleton(NumberUpdatedSignal);

            mediatorMap.mapView(INumberEntry,NumberEntryMediator);
            mediatorMap.mapView(INumberDisplay,NumberDisplayMediator);

            commandMap.mapEvent(NumberEnteredEvent.NUMBER_ENTERED,NumberEnteredCommand);
        }

    }
}
