package hxml;

import haxe.macro.Context;
import haxe.macro.Expr;

class ArgMacro
{
    static var output : String;
    //#if !display
    macro public static function createArgArray() : ExprOf<Array<String>>
    {
        var regex = ~/\s\s(--*[\w;-]*)/g;
        var args = [];
        
        callHaxe();
        var out = output;
        
        while (regex.match(out)) {
            args.push(Context.parse("\"" + regex.matched(1) + "\"", Context.currentPos()));
            out = regex.matchedRight();
        }
        return macro $a{args};
    }
    
    macro public static function createTargetArray() : ExprOf<Array<String>>
    {
        var regex = ~/\[(-[\w;\d]*\|)+(-[\w;\d]*)\]/;
        var targets = [];
        
        callHaxe();
        
        if (regex.match(output)) {
            var pos = regex.matchedPos();
            var list = output.substr(pos.pos + 1, pos.len - 2); //cut off brackets
            
            for (target in list.split("|")) {
                targets.push(Context.parse("\"" + target + "\"", Context.currentPos()));
            }
            
            return macro $a{targets};
        }
        return null;
    }
    
    #if macro
    static function callHaxe() : Void
    {
        if (output == null) {
            var help = new sys.io.Process("haxe", ["-help"]);
            help.exitCode();
            output = help.stderr.readAll().toString();
        }
    }
    
    #end
    //#end
}
