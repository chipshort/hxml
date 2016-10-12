package test;

import haxe.PosInfos;

class Test extends haxe.unit.TestCase
{
    public static function main() : Void
    {
        var r = new haxe.unit.TestRunner();
        r.add(new HxmlTest());
        r.add(new ArgMacroTest());
        
        r.run();
    }
    
    function assertDeepEq<T>(expected: T , actual: T,  ?c : PosInfos) : Void
    {
        currentTest.done = true;
		if (!deepEquals(actual, expected)) {
			currentTest.success = false;
			currentTest.error   = "expected '" + expected + "' but was '" + actual + "'";
			currentTest.posInfos = c;
			throw currentTest;
		}
    }
    
    function deepEquals<T>(v1 : T, v2 : T) : Bool
    {
        return haxe.Serializer.run(v1) == haxe.Serializer.run(v2);
        //return false;
    }
}
