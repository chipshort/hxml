# hxml
A simple hxml parser for Haxe.

## Installation
`haxelib git hxml https://github.com/chipshort/hxml.git`

## Examples
Parse hxml files:
```Haxe
var hxml = Hxml.parse("-cp src");
#if sys
var hxml = Hxml.parseFile("test.hxml");
#end
```
Extract specific types of arguments:
```Haxe
var hxml = Hxml.parse("-cp src\n-main test.Main\n-lib hxml\n-D define\n-D dump=pretty\n-js test.js");

var libs = hxml.getLibs(); //["hxml"]
var defs = hxml.getDefines(); //["define" => null, "dump" => "pretty"]
var targets = hxml.getTargets(); //[{ target: "-js", path: "test.js" }]
```
Resolve included hxml files:
```Haxe
var hxml = Hxml.parse("-cp src\ntest.hxml");
hxml.resolveIncludes("unit");
```
Generate seperate hxmls from hxmls with "--each" or "--next" in them:
```Haxe
var hxml = Hxml.parse("-cp src\n-main Main\n--each\n-js js.js\n--next\n-hl test");
var targets = hxml.generateTargetHxmls();
```
