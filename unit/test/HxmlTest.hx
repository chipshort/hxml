package test;

import hxml.Hxml;

class HxmlTest extends test.Test
{
    public function testBasic() : Void
    {
        var hxml = Hxml.parse("-cp src\ntest.Main");
        
        assertEquals(Std.string(StandardArg("-cp", ["src"])), Std.string(hxml[0]));
    }
    
    public function testLibs() : Void
    {
        var hxml = Hxml.parse("-lib hexMachina\n-lib hxcpp");
        var libs = hxml.getLibs();
        
        assertEquals(Std.string(libs), Std.string(["hexMachina", "hxcpp"]));
    }
    
    public function testDefs() : Void
    {
        var hxml = Hxml.parse("-D dce=no\n-D dump=pretty\n-D js-es5");
        var defs = hxml.getDefines();
        
        var defines : Map<String, String> = ["dce" => "no", "dump" => "pretty", "js-es5" => null];
        assertEquals(Std.string(defs), Std.string(defines));
    }
    
    public function testTolerance() : Void
    {
        var result = null;
        try {
            result = Hxml.parse("-unknownArgument", false); //should throw because of invalid hxml
        }
        catch (e : Dynamic) {
        }
        assertEquals(null, result);
        
        
        result = null;
        try {
            result = Hxml.parse("-unknownArgument", true); //should be ignored
        }
        catch (e : Dynamic) {
        }
        assertDeepEq([], result);
    }
    
    public function testComment() : Void
    {
        var hxml = Hxml.parse("#abc\n-D dump=pretty\n#-D js-es5");
        var expected : Hxml = [
            Comment("abc"),
            StandardArg("-D", ["dump=pretty"]),
            Comment("-D js-es5")
        ];
        
        assertDeepEq(hxml, expected);
    }
    
    public function testTargets() : Void
    {
        var hxml = Hxml.parse("#abc\n-js js.js\n-hl test");
        var targets = hxml.getTargets();
        
        assertEquals(Std.string(targets[0]), Std.string({
            target: "-js",
            path: "js.js"
        }));
        
        assertEquals(Std.string(targets[1]), Std.string({
            target: "-hl",
            path: "test"
        }));
    }
    
    public function testGenerateTargetHxmls() : Void
    {
        var hxml = Hxml.parse("-cp src\n-main Main\n--each\n-js js.js\n--next\n-hl test");
        var targets = hxml.generateTargetHxmls();
        
        for (target in targets) {
            assertEquals(Std.string([
                StandardArg("-cp", ["src"]),
                StandardArg("-main", ["Main"])
            ]), Std.string(target.slice(0, 2)));
        }
    }
    
    public function testToString() : Void
    {
        var input = "-cp src\n-main Main\n-js test.js";
        var hxml = Hxml.parse(input);
        var output = hxml.toString();
        assertEquals(input, output);
        
        input = StringTools.replace(input, "\n", " ");
        output = hxml.toString(" ");
        assertEquals(input, output);
    }
    
    #if sys
    public function testParseFile() : Void
    {
        var hxml = Hxml.parseFile("unit/test.hxml");
        
        assertEquals(Std.string(HxmlInclude("folder/test2.hxml")), Std.string(hxml[0]));
    }
    
    public function testResolveIncludes() : Void
    {
        var hxml = Hxml.parseFile("unit/test.hxml");
        hxml.resolveIncludes("unit");
        
        for (arg in hxml) {
            assertFalse(arg.match(HxmlInclude(_)));
        }
    }
    #end
    
    
}
