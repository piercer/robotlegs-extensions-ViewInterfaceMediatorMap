package org.robotlegs.mvcs
{

    import flash.display.DisplayObjectContainer;

    import org.robotlegs.base.InterfaceEnabledMediatorMap;
    import org.robotlegs.core.IMediatorMap;

    import org.robotlegs.mvcs.SignalContext

    public class ViewInterfaceMappingSignalContext extends SignalContext
    {


        public function ViewInterfaceMappingSignalContext(contextView:DisplayObjectContainer = null, autoStartup:Boolean = true)
		{
			super(contextView, autoStartup);
		}

        /**
         * @inheritDoc
         */
        override protected function get mediatorMap():IMediatorMap
        {
            return _mediatorMap ||= new InterfaceEnabledMediatorMap(contextView, createChildInjector(), reflector);
        }


    }

}
