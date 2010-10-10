/*
 * Copyright (c) 2009 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */
package org.robotlegs.mvcs
{
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;

	import mx.containers.Canvas;

	import org.flexunit.Assert;
	import org.flexunit.async.Async;
	import org.fluint.uiImpersonation.UIImpersonator;
	import org.robotlegs.base.ContextEvent;
	import org.robotlegs.mvcs.support.TestViewInterfaceMappingSignalContext;
	import org.robotlegs.mvcs.support.TestContextView;

	public class ViewInterfaceMappingSignalContextTests
	{
		private var context:TestViewInterfaceMappingSignalContext;
		private var contextView:DisplayObjectContainer;

		[Before(ui)]
		public function runBeforeEachTest():void
		{
			contextView = new Canvas()
			UIImpersonator.addChild(contextView);
		}

		[After(ui)]
		public function runAfterEachTest():void
		{
			UIImpersonator.removeAllChildren();
		}

		[Test]
		public function autoStartupWithViewComponent():void
		{
			context = new TestViewInterfaceMappingSignalContext(contextView, true);
			Assert.assertTrue("Context should have started", context.startupComplete);
		}

		[Test]
		public function autoStartupWithLateViewComponent():void
		{
			context = new TestViewInterfaceMappingSignalContext(null, true);
			Assert.assertFalse("Context should NOT have started", context.startupComplete);
			context.contextView = contextView;
			Assert.assertTrue("Context should have started", context.startupComplete);
		}

		[Test]
		public function manualStartupWithViewComponent():void
		{
			context = new TestViewInterfaceMappingSignalContext(contextView, false);
			Assert.assertFalse("Context should NOT have started", context.startupComplete);
			context.startup();
			Assert.assertTrue("Context should now be started", context.startupComplete);
		}

		[Test]
		public function manualStartupWithLateViewComponent():void
		{
			context = new TestViewInterfaceMappingSignalContext(null, false);
			Assert.assertFalse("Context should NOT have started", context.startupComplete);
			context.contextView = contextView;
			context.startup();
			Assert.assertTrue("Context should now be started", context.startupComplete);
		}

		[Test(async, timeout="3000")]
		public function autoStartupWithViewComponentAfterAddedToStage():void
		{
			contextView = new TestContextView();
			context = new TestViewInterfaceMappingSignalContext(contextView, true);
			Async.handleEvent(this, context, ContextEvent.STARTUP_COMPLETE, handleContextAutoStartupOnAddedToStage);

			Assert.assertFalse("Context should NOT be started", context.startupComplete);
			UIImpersonator.addChild(contextView);
		}

		[Test(async, timeout="3000")]
		public function autoStartupWithLateViewComponentAfterAddedToStage():void
		{
			contextView = new TestContextView();
			context = new TestViewInterfaceMappingSignalContext(null, true);
			Async.handleEvent(this, context, ContextEvent.STARTUP_COMPLETE, handleContextAutoStartupOnAddedToStage);
			Assert.assertFalse("Context should NOT be started", context.startupComplete);
			context.contextView = contextView;
			Assert.assertFalse("Context should still NOT be started", context.startupComplete);
			UIImpersonator.addChild(contextView);
		}

		private function handleContextAutoStartupOnAddedToStage(event:ContextEvent, param:*):void
		{
			Assert.assertTrue("Context should be started", context.startupComplete);
		}

		[Test(async, timeout="3000")]
		public function manualStartupWithViewComponentAfterAddedToStage():void
		{
			contextView = new TestContextView();
			context = new TestViewInterfaceMappingSignalContext(contextView, false);
			Async.handleEvent(this, contextView, Event.ADDED_TO_STAGE, handleContextManualStartupOnAddedToStage);
			Assert.assertFalse("Context should NOT be started", context.startupComplete);
			UIImpersonator.addChild(contextView);
		}

		private function handleContextManualStartupOnAddedToStage(event:Event, param:*):void
		{
			Assert.assertFalse("Context should NOT be started", context.startupComplete);
			context.startup();
			Assert.assertTrue("Context should now be started", context.startupComplete);
		}

		[Test]
		public function contextInitializationComplete():void
		{
			context = new TestViewInterfaceMappingSignalContext(contextView);
			Assert.assertTrue("Context should be initialized", context.isInitialized);
		}
	}
}