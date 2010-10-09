/*
 * Copyright (c) 2009 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */

package org.robotlegs
{
	import org.robotlegs.base.BaseTestSuite;
	import org.robotlegs.mvcs.MvcsTestSuite;

	[Suite]
	[RunWith("org.flexunit.runners.Suite")]
	public class InterfaceMappingTestSuite
	{
		public var baseTestSuite:BaseTestSuite;
		public var mvcsTestSuite:MvcsTestSuite;
	}
}