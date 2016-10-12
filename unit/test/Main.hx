package test;

class Main
{
    public static function main() : Void
    {
        var r = new haxe.unit.TestRunner();
        r.add(new HxmlTest());
        r.add(new ArgMacroTest());
        
        r.run();
    }
}
