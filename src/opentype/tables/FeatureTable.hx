package opentype.tables;

@:structInit
class FeatureTable {
    public function new(tag, feature) {
        this.tag = tag;  
        this.feature = feature;
    }

    public var tag : String;
    public var feature : Feature;
}

@:structInit
class Feature {
    public function new(featureParams, lookupListIndexes) {
        this.featureParams = featureParams;  
        this.lookupListIndexes = lookupListIndexes;
    }

    public var featureParams : Int;
    public var lookupListIndexes : Array<Int>;
}

