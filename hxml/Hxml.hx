package hxml;

using StringTools;

@:forward
@:arrayAccess
abstract Hxml(Array<Arg>) from Array<Arg> to Array<Arg>
{
    static var typeRegex = ~/(([a-z]|\d|_)+\.)*[A-Z]\w*/;
    /** A list of possible arguments, extracted from "haxe -help" by a macro **/
    static var possibleArgs = ArgMacro.createArgArray();
    /** A list of possible targets, extracted from "haxe -help" by a macro **/
    static var possibleTargets = ArgMacro.createTargetArray();
    
    public function new()
    {
        this = new Array<Arg>();
    }
    
    #if sys
    /**
            Parses a the given file.
    **/
    public static inline function parseFile(file : String, tolerant = false) : Hxml
    {
        var content = sys.io.File.getContent(file);
        var hxml = parse(content, tolerant);
        
        return hxml;
    }
    
    /**
            Resolves all the hxml includes within this hxml
    **/
    public inline function resolveIncludes(folder : String, tolerant = false)
    {
        var result = new Hxml();
        
        for (arg in this) {
            switch(arg) {
                case HxmlInclude(f):
                    var parsed = parseFile(haxe.io.Path.join([folder, f]), tolerant);
                    parsed.resolveIncludes(folder, tolerant);
                    result = result.concat(parsed);
                case a:
                    result.push(a);
            }
        }
        
        this = result;
    }
    #end
    
    /**
            Looks for "--each" and "--next" and generates
            one hxml for each compilation task
    **/
    public function generateTargetHxmls() : Array<Hxml>
    {
        var result = new Array<Hxml>();
        
        var each = new Hxml();
        var current = new Hxml();
        
        for (arg in this) {
            switch(arg) {
                case StandardArg("--each", _):
                    var e = each;
                    each = current;
                    current = e;
                case StandardArg("--next", _):
                    result.push(each.concat(current));
                    current = new Hxml();
                case a:
                    current.push(a);
            }
        }
        
        if (current.length > 0)
            result.push(each.concat(current));
        
        return result;
    }
    
    /**
            Returns a list of all "-lib" arguments within this hxml
    **/
    public function getLibs() : Array<String>
    {
        var libs = new Array<String>();
        
        for (arg in this) {
            switch (arg) {
                case StandardArg("-lib", lib) if (lib != null && lib.length > 0):
                    libs.push(lib[0]);
                default:
            }
        }
        
        return libs;
    }
    
    /**
            Returns a map of all "-D" arguments within this hxml
    **/
    public function getDefines() : Map<String, String>
    {
        var defines = new Map<String, String>();
        
        for (arg in this) {
            switch (arg) {
                case StandardArg("-D", define) if (define != null && define.length > 0):
                    var def = define[0].split("=");
                    
                    if (def.length == 1)
                        defines.set(def[0], null);
                    else
                        defines.set(def[0], def[1]);
                default:
            }
        }
        
        return defines;
    }
    
    /**
            Returns a list of all target arguments within this hxml (e.g. -js test.js, ...)
    **/
    public function getTargets() : Array<{ target : String, path : String }>
    {
        var targets = [];
        
        for (arg in this) {
            switch (arg) {
                case StandardArg(target, path) if (possibleArgs.indexOf(target) != -1 && path != null && path.length > 0):
                    targets.push({
                        target: target,
                        path: path[0]
                    });
                default:
            }
        }
        
        return targets;
    }
    
    public function toString(separator = "\n") : String
    {
        var result = [];
        
        for (arg in this) {
            switch(arg) {
                case StandardArg(arg, params):
                    result.push(arg + " " + params.join(" "));
                case HxmlInclude(file):
                    result.push(file);
                case Module(module):
                    result.push(module);
                case Comment(line):
                    result.push("#" + line);
            }
        }
        
        return result.join(separator);
    }
    
    //TODO: throw on wrong argument number
    /**
            Parses the given hxml content.
            If tolerant is set to true, errors within the hxml do not throw an exception.
    **/
    public static function parse(str : String, tolerant = false) : Hxml
    {
        str = str.replace("\r\n", "\n");
        str = str.replace("\r", "\n");
        
        var hxml = new Hxml();
        
        var lines = str.split("\n");
        for (i in 0 ... lines.length) {
            var line = lines[i];
            var arg = parseArg(line);
            
            if (line.startsWith("#")) {
                hxml.push(Comment(line.substr(1)));
            }
            else if (possibleArgs.indexOf(arg.arg) != -1) {
                hxml.push(StandardArg(arg.arg, arg.params));
            }
            else if (arg.arg.endsWith(".hxml")) {
                hxml.push(HxmlInclude(arg.arg));
            }
            else if (isValidType(arg.arg)) {
                hxml.push(Module(arg.arg));
            }
            else if (!tolerant && line != "") {
                throw "Invalid argument on line " + i;
            }
        }
        
        return hxml;
    }
    
    //TODO: unit test this
    static function parseArg(str : String) : { arg : String, params : Array<String>}
    {
        str = str.trim();
        var split = str.split(" ");
        
        var arg = split.shift();
        var params = new Array<String>();
        
        for (s in split)
            if (s != "")
                params.push(s);
        
        return {
            arg: arg,
            params: params
        };
    }
    
    static function isValidType(typePath : String) : Bool
    {
        if (typeRegex.match(typePath)) {
            var pos = typeRegex.matchedPos();
            return pos.len == typePath.length;
        }
        
        return false;
    }
}

enum Arg
{
    StandardArg(arg : String, params : Array<String>);
    HxmlInclude(file : String);
    Module(module : String);
    Comment(line : String);
    
    //Next;
    //Each;
}
