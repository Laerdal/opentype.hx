package opentype.tables;

//Not implemented yet
@:structInit
class Script {
    public function new(defaultLangSys, langSysRecords) {
        this.defaultLangSys = defaultLangSys;
        this.langSysRecords = langSysRecords;
    }

    public var defaultLangSys : LangSys;
    public var langSysRecords : Array<LangSysRecord>;
}