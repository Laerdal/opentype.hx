package opentype;

import opentype.tables.Tables;

class Font {
    public function new(?options : FontOptions) {
        tables = new Tables();
        position = new Position(this);
    }

    public var outlinesFormat : Flavor;
    public var tables(default, null) : Tables;
    public var position(default, null) : Position;
    public var unitsPerEm : Int;
    public var numGlyphs : Int;
    public var numMetrics : Int;
    public var glyphs : GlyphSet;
    public var _hmtxTableData : Array<HorizontalMetrics>;
    public var kerningPairs : Map<String,Int>;
}

class HorizontalMetrics {
    public function new(advanceWidth, leftSideBearing) {
        this.advanceWidth;
        this.leftSideBearing;
    }
    public var advanceWidth : Int;
    public var leftSideBearing : Int;
}

@:structInit
class FontOptions {
    public function new(
        ?names,
        ?unitsPerEm,
        ?ascender,
        ?descender,
        ?createdTimestamp,
        ?weightClass,
        ?widthClass,
        ?fsSelection,
        ?glyphs
    ) {
        this.names = names;
        this.unitsPerEm = unitsPerEm;
        this.ascender = ascender;
        this.descender = descender;
        this.createdTimestamp = createdTimestamp;
        this.weightClass = weightClass;
        this.widthClass = widthClass;
        this.fsSelection = fsSelection;
        this.glyphs = glyphs;
    }
    public var names : FontNames;
    public var unitsPerEm : Int;
    public var ascender : Int;
    public var descender : Int;
    public var createdTimestamp : Int;
    public var weightClass : String;
    public var widthClass : String;
    public var fsSelection : String;
    public var glyphs : Array<Glyph>;
}

@:structInit
class FontNames {
    public function new(
        ?fontFamily,
        ?fontSubfamily, 
        ?fullName,
        ?postScriptName, 
        ?designer, 
        ?designerURL, 
        ?manufacturer, 
        ?manufacturerURL, 
        ?license, 
        ?licenseURL, 
        ?version, 
        ?description, 
        ?copyright, 
        ?trademark        
    ) {
        this.fontFamily = fontFamily;
        this.fontSubfamily = fontSubfamily; 
        this.fullName = fullName;
        this.postScriptName = postScriptName; 
        this.designer = designer; 
        this.designerURL = designerURL; 
        this.manufacturer = manufacturer; 
        this.manufacturerURL = manufacturerURL; 
        this.license = license; 
        this.licenseURL = licenseURL; 
        this.version = version; 
        this.description = description; 
        this.copyright = copyright; 
        this.trademark = trademark;        
    }
    public var fontFamily : String; 
    public var fontSubfamily : String; 
    public var fullName : String; 
    public var postScriptName : String; 
    public var designer : String; 
    public var designerURL : String; 
    public var manufacturer : String; 
    public var manufacturerURL : String; 
    public var license : String; 
    public var licenseURL : String; 
    public var version : String; 
    public var description : String; 
    public var copyright : String; 
    public var trademark : String; 
}