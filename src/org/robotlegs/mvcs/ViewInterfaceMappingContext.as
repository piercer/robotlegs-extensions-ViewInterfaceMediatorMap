package org.robotlegs.mvcs
{
    import flash.display.DisplayObjectContainer;

    import org.robotlegs.base.InterfaceEnabledMediatorMap;
    import org.robotlegs.core.IMediatorMap;

    public class ViewInterfaceMappingContext extends Context
    {


        public function ViewInterfaceMappingContext(contextView:DisplayObjectContainer = null, autoStartup:Boolean = true)
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
