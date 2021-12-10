package opentype.tables;

interface IScriptTable {
    var scripts(default, null) : Array<ScriptRecord>;
}