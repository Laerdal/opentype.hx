
using buddy.Should;
import opentype.OpenType;
import opentype.Font;
import opentype.Glyph;
import opentype.Layout;
import opentype.tables.ILayoutTable;
import opentype.tables.ScriptRecord;
import opentype.tables.LookupTable;
import opentype.tables.FeatureTable;
import opentype.tables.subtables.ClassDefinition;
import opentype.tables.subtables.Coverage;

class TestLayout extends buddy.BuddySuite {
    public function new() {
        describe('layout.js', {
            var font;
            var layout;
            final notdefGlyph = new Glyph({
                name: '.notdef',
                unicode: 0
                //path: new Path()
            });
            final defaultLayoutTable = new TestLayoutTable(1, [], [],[]);
        
            final glyphs = [notdefGlyph].concat('abcdefghijklmnopqrstuvwxyz'.split('').map(function (c) {
                return new Glyph({
                    name: c,
                    unicode: c.charCodeAt(0)
                    //path: new Path()
                });
            }));
        
            beforeEach(function() {
                font = new Font({
                    names : { fontFamily: 'MyFont', fontSubfamily: 'Medium' },
                    unitsPerEm: 1000,
                    ascender: 800,
                    descender: -200,
                    glyphs: glyphs
                });
                layout = new Layout(font, 'gsub');
                layout.createDefaultTable = function() { return defaultLayoutTable; };
            });
        
            describe('getTable', function() {
                it('must not always create an empty default layout table', {
                    layout.getTable().should.be(null);
                    layout.getTable(false).should.be(null);
                });
        
                it('must create an empty default layout table on demand', {
                    layout.getTable(true).version.should.be(defaultLayoutTable.version);
                    layout.getTable(true).scripts.should.containExactly(defaultLayoutTable.scripts);
                    layout.getTable(true).lookups.should.containExactly(defaultLayoutTable.lookups);
                    layout.getTable(true).features.should.containExactly(defaultLayoutTable.features);
                });
            });        
            describe('getScriptTable', {
                it('must not create a new script table if it does not exist', {
                    layout.getScriptTable('DFLT').should.be(null);
                    layout.getScriptTable('DFLT', false).should.be(null);
                });
        
                it('must create an new script table only on demand and if it does not exist', {
                    final scriptTable = layout.getScriptTable('DFLT', true);
                    scriptTable.should.not.be(null);
                    scriptTable.defaultLangSys.should.not.be(null);
                    layout.getScriptTable('DFLT', true).should.be(scriptTable);//, 'must create only one instance for each tag');

                });
            });
        
            describe('getGlyphClass', function() {
                final classDef1 : ClassDefinition = {
                    format: 1,
                    startGlyph: 0x32,
                    classes: [
                        0, 1, 0, 1, 0, 1, 2, 1, 0, 2, 1, 1, 0,
                        0, 0, 2, 2, 0, 0, 1, 0, 0, 0, 0, 2, 1
                    ]
                };
        
                final classDef2 : ClassDefinition = {
                    format: 2,
                    ranges: [
                        { start: 0x46, end: 0x47, value: 2 }, //value is classId
                        { start: 0x49, end: 0x49, value: 2 }, //value is classId
                        { start: 0xd2, end: 0xd3, value: 1 } //value is classId
                    ]
                };

                it('should find a glyph class in a format 1 class definition table', {
                    layout.getGlyphClass(classDef1, 0x32).should.be(0);
                    layout.getGlyphClass(classDef1, 0x33).should.be(1);
                    layout.getGlyphClass(classDef1, 0x34).should.be(0);
                    layout.getGlyphClass(classDef1, 0x38).should.be(2);
                    layout.getGlyphClass(classDef1, 0x4a).should.be(2);
                    layout.getGlyphClass(classDef1, 0x4b).should.be(1);
        
                    // Any glyph not included in the range of covered glyph IDs automatically belongs to Class 0.
                    layout.getGlyphClass(classDef1, 0x31).should.be(0);
                    layout.getGlyphClass(classDef1, 0x50).should.be(0);
                });
        
                it('should find a glyph class in a format 2 class definition table', function() {
                    layout.getGlyphClass(classDef2, 0x46).should.be(2);
                    layout.getGlyphClass(classDef2, 0x47).should.be(2);
                    layout.getGlyphClass(classDef2, 0x49).should.be(2);
                    layout.getGlyphClass(classDef2, 0xd2).should.be(1);
                    layout.getGlyphClass(classDef2, 0xd3).should.be(1);
        
                    // Any glyph not covered by a ClassRangeRecord is assumed to belong to Class 0.
                    layout.getGlyphClass(classDef2, 0x45).should.be(0);
                    layout.getGlyphClass(classDef2, 0x48).should.be(0);
                    layout.getGlyphClass(classDef2, 0x4a).should.be(0);
                    layout.getGlyphClass(classDef2, 0xd4).should.be(0);
                });
            });
            describe('getCoverageIndex', function() {
                final cov1 : Coverage = {
                    format: 1,
                    glyphs: [0x4f, 0x125, 0x129]
                };
        
                final cov2 : Coverage = {
                    format: 2,
                    ranges: [
                        { start: 6, end: 6, value: 0 }, //value is index
                        { start: 11, end: 11, value: 1 }, //value is index
                        { start: 16, end: 16, value: 2 }, //value is index
                        { start: 18, end: 18, value: 3 }, //value is index
                        { start: 37, end: 41, value: 4 }, //value is index
                        { start: 44, end: 52, value: 9 }, //value is index
                        { start: 56, end: 62, value: 18 } //value is index
                    ]
                };
                it('should find a glyph in a format 1 coverage table', {
                    layout.getCoverageIndex(cov1, 0x4f).should.be(0);
                    layout.getCoverageIndex(cov1, 0x125).should.be(1);
                    layout.getCoverageIndex(cov1, 0x129).should.be(2);
        
                    layout.getCoverageIndex(cov1, 0x33).should.be(-1);
                    layout.getCoverageIndex(cov1, 0x80).should.be(-1);
                    layout.getCoverageIndex(cov1, 0x200).should.be(-1);
                });
        
                it('should find a glyph in a format 2 coverage table', {
                    layout.getCoverageIndex(cov2, 6).should.be(0);
                    layout.getCoverageIndex(cov2, 11).should.be(1);
                    layout.getCoverageIndex(cov2, 37).should.be(4);
                    layout.getCoverageIndex(cov2, 38).should.be(5);
                    layout.getCoverageIndex(cov2, 56).should.be(18);
                    layout.getCoverageIndex(cov2, 62).should.be(24);
        
                    layout.getCoverageIndex(cov2, 5).should.be(-1);
                    layout.getCoverageIndex(cov2, 8).should.be(-1);
                    layout.getCoverageIndex(cov2, 55).should.be(-1);
                    layout.getCoverageIndex(cov2, 70).should.be(-1);
                });
            });
        });
    }
}

class TestLayoutTable
implements ILayoutTable {
    public function new(version, scripts, lookups, features) {
        this.version = version;
        this.scripts = scripts;
        this.lookups = lookups;
        this.features = features;
    }
    public var version(default, null) : Float;
    public var scripts : Array<ScriptRecord>;
    public var lookups(default, null) : Array<LookupTable>;
    public var features(default, null) : Array<FeatureTable>;    
}