package opentype.tables;

@:structInit
class ScriptRecord 
implements ITag
{
    public function new(tag : String, script : Script) {
        this.tag = tag;
        this.script = script;
    }

    public var tag : String;
    public var script : Script;
}