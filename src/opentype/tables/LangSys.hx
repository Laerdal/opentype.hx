package opentype.tables;

@:structInit
class LangSys {
    public function new(reserved, reqFeatureIndex, featureIndexes) {
        this.reserved = reserved;
        this.reqFeatureIndex = reqFeatureIndex;
        this.featureIndexes = featureIndexes;
    }

    public var reserved : Int;
    public var reqFeatureIndex : Int;
    public var featureIndexes : Array<Int>;

}