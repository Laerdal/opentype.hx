package opentype.tables;

@:structInit
class LangSysRecord {
    public function new(tag, langSys) {
        this.tag = tag;
        this.langSys = langSys;
    }

    public var tag : String;
    public var langSys : LangSys;
}