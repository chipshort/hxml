package test;

import hxml.ArgMacro;

class ArgMacroTest extends test.Test
{
    public function testCp() : Void
    {
        var args = ArgMacro.createArgArray();
        
        assertTrue(args.indexOf("-cp") != -1);
    }
    
    public function testTargets() : Void
    {
        var targets = ArgMacro.createTargetArray();
        
        assertTrue(targets.indexOf("-js") != -1);
    }
}
