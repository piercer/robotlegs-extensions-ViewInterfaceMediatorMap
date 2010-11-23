/*
 * Copyright (c) 2009 the original author or authors
 * 
 * Permission is hereby granted to use, modify, and distribute this file 
 * in accordance with the terms of the license agreement accompanying it.
 */

package org.robotlegs.base
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.utils.Dictionary;
	import flash.utils.describeType;
	import flash.utils.getQualifiedClassName;
	
	import org.robotlegs.core.IInjector;
	import org.robotlegs.core.IMediator;
	import org.robotlegs.core.IMediatorMap;
	import org.robotlegs.core.IReflector;
	
	/**
	 * An abstract <code>IMediatorMap</code> implementation
	 */
	public class ViewInterfaceMediatorMap extends ViewMapBase implements IMediatorMap
	{
		/**
		 * @private
		 */
		protected static const enterFrameDispatcher:Sprite = new Sprite();
		
		/**
		 * @private
		 */
		protected var mediatorByView:Dictionary;
		
		/**
		 * @private
		 */
		protected var mappingConfigByView:Dictionary;
		
		/**
		 * @private
		 */
		protected var mappingConfigByViewClassName:Dictionary;
		
		/**
		 * @private
		 */
		protected var mediatorsMarkedForRemoval:Dictionary;
		
		/**
		 * @private
		 */
		protected var unmappedViews:Dictionary;
		
		/**
		 * @private
		 */
		protected var hasMediatorsMarkedForRemoval:Boolean;
		
		/**
		 * @private
		 */
		protected var reflector:IReflector;
		
		//---------------------------------------------------------------------
		//  Constructor
		//---------------------------------------------------------------------
		
		/**
		 * Creates a new <code>MediatorMap</code> object
		 *
		 * @param contextView The root view node of the context. The map will listen for ADDED_TO_STAGE events on this node
		 * @param injector An <code>IInjector</code> to use for this context
		 * @param reflector An <code>IReflector</code> to use for this context
		 */
		public function ViewInterfaceMediatorMap(contextView:DisplayObjectContainer, injector:IInjector, reflector:IReflector)
		{
			super(contextView, injector);
			
			this.reflector = reflector;
			
			// mappings - if you can do it with fewer dictionaries you get a prize
			this.mediatorByView = new Dictionary(true);
			this.mappingConfigByView = new Dictionary(true);
			this.mappingConfigByViewClassName = new Dictionary(false);
			this.mediatorsMarkedForRemoval = new Dictionary(false);
			this.unmappedViews = new Dictionary(false);
		}
		
		//---------------------------------------------------------------------
		//  API
		//---------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		public function mapView(viewClassOrName:*, mediatorClass:Class, injectViewAs:* = null, autoCreate:Boolean = true, autoRemove:Boolean = true):void
		{
			var viewClassName:String = reflector.getFQCN(viewClassOrName);

			if (mappingConfigByViewClassName[viewClassName] != null)
				throw new ContextError(ContextError.E_MEDIATORMAP_OVR + ' - ' + mediatorClass);

			if (!reflector.classExtendsOrImplements(mediatorClass, IMediator))
				throw new ContextError(ContextError.E_MEDIATORMAP_NOIMPL + ' - ' + mediatorClass);

			unmappedViews = new Dictionary(false);
			var config:MappingConfig = new MappingConfig();
			config.mediatorClass = mediatorClass;
			config.autoCreate = autoCreate;
			config.autoRemove = autoRemove;
			if (injectViewAs)
			{
                if (injectViewAs is Array)
                {
                    config.typedViewClasses = (injectViewAs as Array).concat();
                }
                else if (injectViewAs is Class)
                {
                    config.typedViewClasses = [injectViewAs];
                }
			}
			else if (viewClassOrName is Class)
			{
				config.typedViewClasses = [viewClassOrName];
			}
			mappingConfigByViewClassName[viewClassName] = config;
            if (autoCreate || autoRemove)
            {
                viewListenerCount++;
                if (viewListenerCount == 1)
                    addListeners();
            }

            // This was a bad idea - causes unexpected eager instantiation of object graph
            //
            // If
            //
            // 1) autoCreate is true and we already have a contextView
            // 2) A config exists for the contextView, and
            // 3) the config we have just added is that config
            //
            // Then we should autowire the contextView now.
            //
            if (autoCreate && contextView)
            {
                var config2:MappingConfig = getMappingConfig(contextView);
                if (config == config2)
                {
                    createMediatorUsing(contextView, viewClassName, config);
                }
            }
		}

		/**
		 * @inheritDoc
		 */
		public function unmapView(viewClassOrName:*):void
		{
			var viewClassName:String = reflector.getFQCN(viewClassOrName);
			var config:MappingConfig = mappingConfigByViewClassName[viewClassName];
            if (config && (config.autoCreate || config.autoRemove))
            {
                viewListenerCount--;
                if (viewListenerCount == 0)
                    removeListeners();
                for each (var mappedConcreteViewClassName:String in config.mappedConcreteClasses)
                {
                    delete mappingConfigByViewClassName[mappedConcreteViewClassName];
                }
            }
			delete mappingConfigByViewClassName[viewClassName];
			unmappedViews = new Dictionary(false);
		}

		/**
		 * @inheritDoc
		 */
		public function createMediator(viewComponent:Object):IMediator
		{
            return createMediatorUsing(viewComponent);
		}
		
		/**
		 * @inheritDoc
		 */
		public function registerMediator(viewComponent:Object, mediator:IMediator):void
		{
			injector.mapValue(reflector.getClass(mediator), mediator);
			mediatorByView[viewComponent] = mediator;
			mappingConfigByView[viewComponent] = getMappingConfig(viewComponent);
			mediator.setViewComponent(viewComponent);
			mediator.preRegister();
		}

		/**
		 * @inheritDoc
		 */
		public function removeMediator(mediator:IMediator):IMediator
		{
			if (mediator)
			{
				var viewComponent:Object = mediator.getViewComponent();
				delete mediatorByView[viewComponent];
				delete mappingConfigByView[viewComponent];
				mediator.preRemove();
				mediator.setViewComponent(null);
				injector.unmap(reflector.getClass(mediator));
			}
			return mediator;
		}

		/**
		 * @inheritDoc
		 */
		public function removeMediatorByView(viewComponent:Object):IMediator
		{
			return removeMediator(retrieveMediator(viewComponent));
		}
		
		/**
		 * @inheritDoc
		 */
		public function retrieveMediator(viewComponent:Object):IMediator
		{
			return mediatorByView[viewComponent];
		}

		/**
		 * @inheritDoc
		 */
		public function hasMapping(viewClassOrName:*):Boolean
		{
			var viewClassName:String = reflector.getFQCN(viewClassOrName);
			return (mappingConfigByViewClassName[viewClassName] != null);
		}

		/**
		 * @inheritDoc
		 */
		public function hasMediatorForView(viewComponent:Object):Boolean
		{
			return mediatorByView[viewComponent] != null;
		}
		
		/**
		 * @inheritDoc
		 */
		public function hasMediator(mediator:IMediator):Boolean
		{
			for each (var med:IMediator in mediatorByView)
				if (med == mediator)
					return true;
			return false;
		}
		
		//---------------------------------------------------------------------
		//  Internal
		//---------------------------------------------------------------------
		
		/**
		 * @private
		 */		
		protected override function addListeners():void
		{
			if (contextView && enabled)
			{
				contextView.addEventListener(Event.ADDED_TO_STAGE, onViewAdded, useCapture, 0, true);
				contextView.addEventListener(Event.REMOVED_FROM_STAGE, onViewRemoved, useCapture, 0, true);
			}
		}
		
		/**
		 * @private
		 */		
		protected override function removeListeners():void
		{
			if (contextView)
			{
				contextView.removeEventListener(Event.ADDED_TO_STAGE, onViewAdded, useCapture);
				contextView.removeEventListener(Event.REMOVED_FROM_STAGE, onViewRemoved, useCapture);
			}
		}
		
		/**
		 * @private
		 */		
		protected override function onViewAdded(e:Event):void
		{
			if (mediatorsMarkedForRemoval[e.target])
			{
				delete mediatorsMarkedForRemoval[e.target];
				return;
			}
            var viewClassName:String = getQualifiedClassName(e.target);
			var config:MappingConfig = getMappingConfig(e.target);
			if (config && config.autoCreate)
                createMediatorUsing(e.target, viewClassName, config);
        }
		
        /**
		 * @private
		 */
		protected function createMediatorUsing(viewComponent:Object, viewClassName:String = '', config:MappingConfig = null):IMediator
		{
            var mediator:IMediator = mediatorByView[viewComponent];
            if (mediator == null)
            {
                config ||= getMappingConfig(viewComponent, viewClassName);
                if (config)
                {
                    for each (var claxx:Class in config.typedViewClasses)
                    {
                        injector.mapValue(claxx, viewComponent);
                    }
                    mediator = injector.instantiate(config.mediatorClass);
                    for each (var clazz:Class in config.typedViewClasses)
                    {
                        injector.unmap(clazz);
                    }
                    registerMediator(viewComponent, mediator);
                }
            }
            return mediator;
		}

        /**
		 * Flex framework work-around part #5
		 */
		protected function onViewRemoved(e:Event):void
		{
			var config:MappingConfig = mappingConfigByView[e.target];
			if (config && config.autoRemove)
			{
				mediatorsMarkedForRemoval[e.target] = e.target;
				if (!hasMediatorsMarkedForRemoval)
				{
					hasMediatorsMarkedForRemoval = true;
					enterFrameDispatcher.addEventListener(Event.ENTER_FRAME, removeMediatorLater);
				}
			}
		}
		
		/**
		 * Flex framework work-around part #6
		 */
		protected function removeMediatorLater(event:Event):void
		{
			enterFrameDispatcher.removeEventListener(Event.ENTER_FRAME, removeMediatorLater);
			for each (var view:DisplayObject in mediatorsMarkedForRemoval)
			{
				if (!view.stage)
				{
					removeMediatorByView(view);
				}
				delete mediatorsMarkedForRemoval[view];
			}
			hasMediatorsMarkedForRemoval = false;
		}
		
		private function getMappingConfig(viewComponent:Object, viewClassName:String = ''):MappingConfig
		{
			viewClassName ||= getQualifiedClassName(viewComponent);
			if (unmappedViews[viewClassName])
			{
				return null;
			}
			var config:MappingConfig = mappingConfigByViewClassName[viewClassName];
			if (!config)
			{
                //
				// This stuff should be handled by the Reflector
                //
				var classXML:XML = describeType(viewComponent);
				for each (var implementedInterface:XML in classXML.implementsInterface)
				{
					var interfaceName:String = implementedInterface.@type;
					config = mappingConfigByViewClassName[interfaceName];
                    //
					// We can't cache the config by throwing into mappingConfigByViewClassName
					// as there is no way to invalidate that action
                    //
					if (config)
					{
						mappingConfigByViewClassName[viewClassName]=config;
						config.mappedConcreteClasses.push(viewClassName);
						return config;
					}
				}
                //
                // If we get here the no matching interface mapping was
                // found so we add this className to the list of unmapped Views
                //
                unmappedViews[viewClassName]=1;
			}
			return config;
		}

	}
}

class MappingConfig
{
	public var mediatorClass:Class;
	public var typedViewClasses:Array;
	public var autoCreate:Boolean;
	public var autoRemove:Boolean;
	public var mappedConcreteClasses:Array=[];
}
