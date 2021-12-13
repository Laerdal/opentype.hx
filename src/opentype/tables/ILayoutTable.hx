package opentype.tables;

interface ILayoutTable {
    var version(default, null) : Float;
    var scripts : Array<ScriptRecord>;
    var lookups(default, null) : Array<LookupTable>;
    var features(default, null) : Array<FeatureTable>;    
}