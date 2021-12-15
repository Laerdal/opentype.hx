
using buddy.Should;
import opentype.Parser;
import opentype.tables.subtables.ILookup;
import opentype.tables.subtables.Lookup;
using TestUtil;

class TestParser extends buddy.BuddySuite {
    public function new() {
        // A test suite:
        describe("Test that Parser", {
            describe('parseByte', {
                it("can parse a byte", {
                    final p = new Parser('1234'.unhex(), 0);
                    p.parseByte().should.be(0x12);
                    p.relativeOffset.should.be(1);
                    p.parseByte().should.be(0x34);
                    p.relativeOffset.should.be(2);
                });
            });

            describe('parseChar', {
                it("can parse a character", {
                    final p = new Parser('0080'.unhex(), 0);
                    p.parseChar();
                    p.relativeOffset.should.be(1);
                    p.parseChar();
                    p.relativeOffset.should.be(2);
                });
            });

            describe('parseUShort', {
                it("can parse a 16 bit integer", {
                    final p = new Parser('0080'.unhex(), 0);
                    p.parseUShort().should.be(0x80);
                    p.relativeOffset.should.be(2);
                });
            });

            describe('parsePointer', {
                it("can parse 16 bit offset from the stream", {
                    final p = new Parser('0004 1234 FACE 5F5F'.unhex(), 0);
                    p.parsePointer().parseUShort().should.be(0xFACE);
                    p.relativeOffset.should.be(2);
                });
            });

            describe('parseUShortList', {
                it('can parse an empty list', {
                    final p = new Parser('0000'.unhex(), 0);
                    p.parseUShortList().should.containExactly([]);
                    p.relativeOffset.should.be(2);
                });
                it('can parse a list', {
                    final p = new Parser('0003 1234 DEAD BEEF'.unhex(), 0);
                    p.parseUShortList().should.containExactly([0x1234, 0xdead, 0xbeef]);
                    p.relativeOffset.should.be(8);
                });
                it('can parse a list of predefined length', {
                    final p = new Parser('1234 DEAD BEEF 5678 9ABC'.unhex(), 0);
                    p.parseUShortListOfLength(3).should.containExactly([0x1234, 0xdead, 0xbeef]);
                    p.relativeOffset.should.be(6);
                });
            });

            describe('parseList', {
                it('can parse a list of values', {
                    final data = '0003 12 34 56 78 9A BC';
                    final p = new Parser(data.unhex(), 0);
                    p.parseList(p.parseUShort).should.containExactly([0x1234, 0x5678, 0x9abc]);
                    p.relativeOffset.should.be(8);
                });
            });            
            describe('parseListOfLength', {
                it('can parse a list of values of predefined length', {
                    final data = '12 34 56 78 9A BC';
                    final p = new Parser(data.unhex(), 0);
                    p.parseListOfLength(3, p.parseUShort).should.containExactly([0x1234, 0x5678, 0x9abc]);
                    p.relativeOffset.should.be(6);
                });
            });            
            describe('parseRecordList', {
                it('can parse a list of records', {
                    final data = '0002 12 34 56 78 9A BC';
                    final p = new Parser(data.unhex(), 0);
                    var result = p.parseRecordList([{ name: "a", parseFn : Parser.byte }, { name: "b", parseFn : Parser.uShort }]);
                    result[0][0].name.should.be("a");
                    result[0][0].value.should.be(0x12);
                    result[0][1].name.should.be("b");
                    result[0][1].value.should.be(0x3456);
                    result[1][0].name.should.be("a");
                    result[1][0].value.should.be(0x78);
                    result[1][1].name.should.be("b");
                    result[1][1].value.should.be(0x9abc);
                    p.relativeOffset.should.be(8);                
                });
                it('can parse an empty list of records', {
                    final data = '0000';
                    final p = new Parser(data.unhex(), 0);
                    p.parseRecordList([{ name : "a", parseFn : Parser.byte }, { name: "b", parseFn : Parser.uShort }]).should.containExactly([]);
                    p.relativeOffset.should.be(2);
                });
            });
            describe('parseRecordListOfLength', {
                it('can parse a list of records of predefined length', {
                    final data = '12 34 56 78 9A BC';
                    final p = new Parser(data.unhex(), 0);
                    var result = p.parseRecordListOfLength(2, [{ name: "a", parseFn: Parser.byte }, { name: "b", parseFn: Parser.uShort }]);
                    result[0][0].name.should.be("a");
                    result[0][0].value.should.be(0x12);
                    result[0][1].name.should.be("b");
                    result[0][1].value.should.be(0x3456);
                    result[1][0].name.should.be("a");
                    result[1][0].value.should.be(0x78);
                    result[1][1].name.should.be("b");
                    result[1][1].value.should.be(0x9abc);
                    p.relativeOffset.should.be(6);
                });
            });

            describe('parseListOfListsOf16', {
                it('can parse a list of lists of 16-bit integers', {
                    final data = '0003 0008 000E 0016' +      // 3 lists
                        '0002 1234 5678' +                  // list 1
                        '0003 DEAD BEEF FADE' +             // list 2
                        '0001 9876';                        // list 3
                    final p = new Parser(data.unhex(), 0);
                    final result = p.parseListOfListsOfUShort();
                    result[0].should.containExactly([0x1234, 0x5678]);
                    result[1].should.containExactly([0xdead, 0xbeef, 0xfade]);
                    result[2].should.containExactly([0x9876]);
                });
                it('can parse an empty list of lists', {
                    final p = new Parser('0000'.unhex(), 0);
                    p.parseListOfListsOfUShort().should.containExactly([]);
                });
                it('can parse list of empty lists', {
                    final p = new Parser('0001 0004 0000'.unhex(), 0);
                    var result = p.parseListOfListsOfUShort();
                    result.length.should.be(1);
                    result[0].should.containExactly([]);
                });
            });
            describe('parseListOfLists', {
                it('can parse a list of lists of records', {
                    final data = '0002 0006 0012' +                   // 2 lists
                        '0002 0006 0009 12 34 56 78 9A BC' +        // list 1
                        '0001 0004 DE F0 12 ';                       // list 2
        
                    final p = new Parser(data.unhex(), 0);
                    function parseRecord() {
                        return { a: p.parseByte(), b: p.parseUShort() };
                    }
        
                    var result = p.parseListOfLists(parseRecord);

                    result[0][0].a.should.be(0x12);
                    result[0][0].b.should.be(0x3456);
                    result[0][1].a.should.be(0x78);
                    result[0][1].b.should.be(0x9abc);
                    result[1][0].a.should.be(0xde);
                    result[1][0].b.should.be(0xf012);
                });
            });

            describe('parseCoverage', {
                it('should parse a CoverageFormat1 table', {
                    // https://www.microsoft.com/typography/OTSPEC/chapter2.htm Example 5
                    final data = '0004 1234' +                // coverageOffset + filler
                        '0001 0005 0038 003B 0041 0042 004A';
                    final p = new Parser(data.unhex(), 4);
                    var coverage = Parser.coverage(p);
                    coverage.format.should.be(1);
                    coverage.glyphs.should.containExactly([0x38, 0x3b, 0x41, 0x42, 0x4a]);
                    coverage.ranges.should.containExactly([]);
                    p.relativeOffset.should.be(14);
                });
                it('should parse a CoverageFormat2 table', {
                    // https://www.microsoft.com/typography/OTSPEC/chapter2.htm Example 6
                    final data = '0004 1234' +                // coverageOffset + filler
                        '0002 0001 004E 0057 0000';
                    final p = new Parser(data.unhex(), 4);
                    var coverage = Parser.coverage(p);
                    coverage.format.should.be(2);
                    coverage.glyphs.should.containExactly([]);
                    coverage.ranges[0].start.should.be(0x4e);
                    coverage.ranges[0].end.should.be(0x57);
                    coverage.ranges[0].value.should.be(0);
                    p.relativeOffset.should.be(10);
                });
            });            

            describe('parseClassDef', {
                it('should parse a ClassDefFormat1 table', {
                    // https://docs.microsoft.com/en-us/typography/opentype/spec/chapter2#example-7-classdefformat1-table-class-array
                    final data = '0001 0032 001A' +
                        '0000 0001 0000 0001 0000 0001 0002 0001 0000 0002 0001 0001 0000' +
                        '0000 0000 0002 0002 0000 0000 0001 0000 0000 0000 0000 0002 0001';
                    final p = new Parser(data.unhex(), 0);
                    var res = p.parseClassDef();
                    res.format.should.be(1);
                    res.startGlyph.should.be(0x32);
                    res.classes.should.containExactly( [
                        0, 1, 0, 1, 0, 1, 2, 1, 0, 2, 1, 1, 0,
                        0, 0, 2, 2, 0, 0, 1, 0, 0, 0, 0, 2, 1
                    ]);
                    p.relativeOffset.should.be(58);
                });
                it('should parse a ClassDefFormat2 table', {
                    // https://docs.microsoft.com/en-us/typography/opentype/spec/chapter2#example-8-classdefformat2-table-class-ranges
                    final data = '0002 0003 0030 0031 0002 0040 0041 0003 00D2 00D3 0001';
                    final p = new Parser(data.unhex(), 0);
                    var res = p.parseClassDef();
                    res.format.should.be(2);
                    res.ranges[0].start.should.be(0x30);
                    res.ranges[0].end.should.be(0x31);
                    res.ranges[0].value.should.be(2);
                    res.ranges[1].start.should.be(0x40);
                    res.ranges[1].end.should.be(0x41);
                    res.ranges[1].value.should.be(3);
                    res.ranges[2].start.should.be(0xd2);
                    res.ranges[2].end.should.be(0xd3);
                    res.ranges[2].value.should.be(1);
                    p.relativeOffset.should.be(22);
                });
            });


            describe('parseScriptList', {
                it('should parse a ScriptList table', {
                    // https://www.microsoft.com/typography/OTSPEC/chapter2.htm Examples 1 & 2
                    final data = '0004 1234' +                // coverageOffset + filler
                        '0003 68616E69 0014 6B616E61 0018 6C61746E 001C' +  // Example 1
                        '0000 0000 0000 0000' +                             // 2 empty Script Tables
                        '000A 0001 55524420 0016' +                         // Example 2
                        '0000 FFFF 0003 0000 0001 0002' +                   // DefLangSys
                        '0000 0003 0003 0000 0001 0002';                    // UrduLangSys
                    final p = new Parser(data.unhex(), 0);
                    var sl = p.parseScriptList();
                    sl[0].tag.should.be('hani');
                    sl[0].script.defaultLangSys.should.be(null);
                    sl[0].script.langSysRecords.should.containExactly([]);
                    sl[1].tag.should.be('kana');
                    sl[1].script.defaultLangSys.should.be(null);
                    sl[1].script.langSysRecords.should.containExactly([]);
                    sl[2].tag.should.be('latn');
                    sl[2].script.defaultLangSys.reserved.should.be(0);
                    sl[2].script.defaultLangSys.reqFeatureIndex.should.be(0xffff);
                    sl[2].script.defaultLangSys.featureIndexes.should.containExactly([0, 1, 2]);
                    sl[2].script.langSysRecords[0].tag.should.be("URD ");
                    sl[2].script.langSysRecords[0].langSys.reserved.should.be(0); 
                    sl[2].script.langSysRecords[0].langSys.reqFeatureIndex.should.be(3); 
                    sl[2].script.langSysRecords[0].langSys.featureIndexes.should.containExactly([0, 1, 2]); 
                    p.relativeOffset.should.be(2);
                });
            });

            describe('parseFeatureList', function() {
                it('should parse a FeatureList table', function() {
                    // https://www.microsoft.com/typography/OTSPEC/chapter2.htm Example 3
                    final data = '0004 0000' +                                // table offset + filler
                        '0003 6C696761 0014 6C696761 001A 6C696761 0022' +  // feature list
                        // There is an error in the online example, count is 3 for the 3rd feature.
                        '0000 0001 0000   0000 0002 0000 0001   0000 0003 0000 0001 0002';
                    final p = new Parser(data.unhex(), 0);
                    var fl = p.parseFeatureList();
                    fl[0].tag.should.be('liga');
                    fl[0].feature.featureParams.should.be(0);
                    fl[0].feature.lookupListIndexes.should.containExactly([0]);
                    fl[1].tag.should.be('liga');
                    fl[1].feature.featureParams.should.be(0);
                    fl[1].feature.lookupListIndexes.should.containExactly([0, 1]);
                    fl[2].tag.should.be('liga');
                    fl[2].feature.featureParams.should.be(0);
                    fl[2].feature.lookupListIndexes.should.containExactly([0, 1, 2]);
                    p.relativeOffset.should.be(2);
                });
            });

            describe('parseLookupList', {
                it('should parse a LookupList table', {
                    // https://www.microsoft.com/typography/OTSPEC/chapter2.htm Example 4
                    final data = '0004 0000' +                    // table offset + filler
                        '0003 0008 0010 0018' +                 // lookup list
                        '0004 000C 0001 0018' +                 // FfiFi lookup
                        '0004 000C 0001 0028' +                 // FflFlFf lookup
                        '0004 000C 0001 0038' +                 // Eszet lookup
                        '1234 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000' +
                        '5678 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000' +
                        '9ABC';
                    final lookupTableParsers : Array<Parser -> Any> = [null, null, null, null, cast Parser.uShort];
                    final p = new Parser(data.unhex(), 0);
                    var res = p.parseLookupList(lookupTableParsers);
                    res[0].lookupType.should.be(4);                   
                    res[0].lookupFlag.should.be(0x000c);              
                    res[0].subTables.should.containExactly([0x1234]);              
                    res[1].lookupType.should.be(4);                   
                    res[1].lookupFlag.should.be(0x000c);              
                    res[1].subTables.should.containExactly([0x5678]);              
                    res[2].lookupType.should.be(4);                   
                    res[2].lookupFlag.should.be(0x000c);              
                    res[2].subTables.should.containExactly([0x9abc]);              
                    p.relativeOffset.should.be(2);
                });
            });            

            describe('getTag', {
                it('can read tag from font Bytes', {
                    final data = '0002 0000'.unhex();
                    Parser.getTag(data, 0).should.be(opentype.BytesHelper.fromCharCodes([0, 2, 0, 0]));
                });
            });
        });
    }
}