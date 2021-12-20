package opentype;

import opentype.tables.Tables;
import opentype.Encoding.IEncoding;
import opentype.Encoding.DefaultEncoding;


class Font {
    public function new(?options : FontOptions) {
        tables = options != null && options.tables != null ? options.tables : new Tables();
        //names = options != null && options.names != null ? options.names : new FontNames();

        if(options != null) {

        }

        glyphs = new GlyphSet(this, options != null && options.glyphs != null ? options.glyphs : []);
        encoding = new DefaultEncoding(this);
        position = new Position(this);


    }

    public var names :  Map<String, Map<String, String>> = [];
    public var outlinesFormat : Flavor;
    public var tables(default, null) : Tables;
    public var position(default, null) : Position;
    public var unitsPerEm : Int;
    public var numGlyphs : Int;
    public var numberOfHMetrics : Int;
    public var glyphs : GlyphSet;
    public var _hmtxTableData : Array<HorizontalMetrics>;
    public var kerningPairs : Map<String,Int>;
    public var encoding : IEncoding;

    /**
    * Retrieve the value of the kerning pair between the left glyph index)
    * and the right glyph (or its index). If no kerning pair is found, return 0.
    * The kerning value gets added to the advance width when calculating the spacing
    * between glyphs.
    * For GPOS kerning, this method uses the default script and language, which covers
    * most use cases. To have greater control, use font.position.getKerningValue .
    * @param  {opentype.Glyph} leftGlyph
    * @param  {opentype.Glyph} rightGlyph
    * @return {Number}
    */
    public function getKerningValueForIndexes(leftIndex : Int, rightIndex : Int) {
        var kerning = 0; 
        if (position.hasKerningTables()) {
            kerning = position.getKerningValue(leftIndex, rightIndex);
        }
        if (kerning != 0) {
            return kerning;
        } else {
            //fallback to kerning tables
            var kp = leftIndex + ',' + rightIndex;
            return kerningPairs.exists(kp) ? kerningPairs[leftIndex + ',' + rightIndex] : 0;
        }
    }

    /**
    * Retrieve the value of the kerning pair between the left glyph
    * and the right glyph. If no kerning pair is found, return 0.
    * The kerning value gets added to the advance width when calculating the spacing
    * between glyphs.
    * For GPOS kerning, this method uses the default script and language, which covers
    * most use cases. To have greater control, use font.position.getKerningValue .
    * @param  {opentype.Glyph} leftGlyph
    * @param  {opentype.Glyph} rightGlyph
    * @return {Number}
    */
    public function getKerningValue(leftGlyph : Glyph, rightGlyph : Glyph) {
        return getKerningValueForIndexes(leftGlyph.index, rightGlyph.index);
    }


    /**
    * Check if the font has a glyph for the given character.
    * @param  {string}
    * @return {Boolean}
    */
    public function hasChar(code : Int) {
        //return this.encoding.charToGlyphIndex(c) != null;
        return encoding.hasChar(code);
    }

    /**
    * Convert the given character to a single glyph index.
    * Note that this function assumes that there is a one-to-one mapping between
    * the given character and a glyph; for complex scripts this might not be the case.
    * @param  {string}
    * @return {Number}
    */
    public function charToGlyphIndex(s) {
        return encoding.charToGlyphIndex(s);
    }

    /**
    * Convert the given character to a single Glyph object.
    * Note that this function assumes that there is a one-to-one mapping between
    * the given character and a glyph; for complex scripts this might not be the case.
    * @param  {string}
    * @return {opentype.Glyph}
    */
    public function charToGlyph(c) : Glyph {
        final glyphIndex = charToGlyphIndex(c);
        return getGlyphByIndex(glyphIndex);
    }

    public function getGlyphByIndex(glyphIndex) : Glyph {
        var glyph = glyphs.get(glyphIndex);
        if (glyph == null) {
            // .notdef
            glyph = glyphs.get(0);
        }
        return glyph;        
    }

    public function getChars() : Array<Int> {
        return encoding.getChars();
    }

    public function getGlyphIndicies() : Array<Int> {
        return encoding.getIndicies();
    }

    public function getKerningPairs(index : Int) {
        return position.getKerningPairs(index);
    }
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
        ?glyphs,
        ?tables
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
        this.tables = tables;
    }
    public var names : FontNames;
    public var unitsPerEm : Int;
    public var ascender : Int;
    public var descender : Int;
    public var createdTimestamp : Int;
    public var weightClass : String;
    public var widthClass : String;
    public var fsSelection : Int;
    public var glyphs : Array<Glyph>;
    public var tables : Tables;
}

@:structInit
class FontNames {
    public function new(
        ?fontFamily,
        ?styleName,
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
        this.styleName = styleName;
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
    public var styleName : String; 
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