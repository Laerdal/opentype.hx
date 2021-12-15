package tables;

using buddy.Should;
import opentype.tables.Gpos; 
import opentype.tables.subtables.Lookup; 
using TestUtil;

class GposTable extends buddy.BuddySuite {

    // Helper that builds a minimal GPOS table to test a lookup subtable.
    function parseLookup(lookupType : Int, subTableData : String) {
        final data = '00010000 000A 000C 000E' +   // header
            '0000' +                                        // ScriptTable - 0 scripts
            '0000' +                                        // FeatureListTable - 0 features
            '0001 0004' +                                   // LookupListTable - 1 lookup table
            '000' + lookupType + '0000 0001 0008' +         // Lookup table - 1 subtable
            subTableData;                                  // sub table start offset: 0x1a
        return Gpos.parse(data.unhex()).lookups[0].subTables[0];
    }

    public function new() {
        describe('tables/gpos.hx', {
            //// Header ///////////////////////////////////////////////////////////////
            it('can parse a GPOS header', {
                final data =
                    '00010000 000A 000C 000E' +     // header
                    '0000' +                        // ScriptTable - 0 scripts
                    '0000' +                        // FeatureListTable - 0 features
                    '0000';                         // LookupListTable - 0 lookups
                var res = Gpos.parse(data.unhex());
                res.version.should.be(1);
                res.scripts.should.containExactly([]);
                res.features.should.containExactly([]);
                res.lookups.should.containExactly([]);
            });
            it('can parse a GPOS header with null pointers', function() {
                final data = '00010000 0000 0000 0000'.unhex();
                var gpos = Gpos.parse(data);
                gpos.version.should.be(1);
                gpos.scripts.should.containExactly([]);
                gpos.lookups.should.containExactly([]);
                gpos.features.should.containExactly([]);
                gpos.lookups.should.containExactly([]);
            });
        
            //// Lookup type 1 ////////////////////////////////////////////////////////
            it('can parse lookup1 SinglePosFormat1', function() {
                // https://docs.microsoft.com/en-us/typography/opentype/spec/gpos#example-2-singleposformat1-subtable
                final data = '0001 0008 0002   FFB0 0002 0001   01B3 01BC 0000';
                var gpos : Lookup = parseLookup(1, data);
                gpos.posFormat.should.be(1);
                gpos.coverage.format.should.be(2);
                gpos.coverage.ranges[0].start.should.be(0x1b3);
                gpos.coverage.ranges[0].end.should.be(0x1bc);
                gpos.coverage.ranges[0].value.should.be(0);
                gpos.value.yPlacement.should.be(-80);
            });
        
            it('can parse lookup1 SinglePosFormat1 with ValueFormat Table and ValueRecord', function() {
                // https://docs.microsoft.com/fr-fr/typography/opentype/spec/gpos#example-14-valueformat-table-and-valuerecord
                final data = '0001 000E 0099   0050 00D2 0018 0020   0002 0001 00C8 00D1 0000   000B 000F 0001 5540   000B 000F 0001 5540';
                var gpos : Lookup = parseLookup(1, data);
                gpos.posFormat.should.be(1);
                gpos.coverage.format.should.be(2);
                gpos.coverage.ranges[0].start.should.be(0xc8);
                gpos.coverage.ranges[0].end.should.be(0xd1);
                gpos.coverage.ranges[0].value.should.be(0);
                gpos.value.xPlacement.should.be(80);
                gpos.value.yAdvance.should.be(210);
                gpos.value.xPlaDevice.should.be(null);
                gpos.value.yAdvDevice.should.be(null);
            });
        
            it('can parse lookup1 SinglePosFormat2', function() {
                // https://docs.microsoft.com/en-us/typography/opentype/spec/gpos#example-3-singleposformat2-subtable
                final data = '0002 0014 0005 0003   0032 0032   0019 0019  000A 000A   0001 0003 004F 0125 0129';
                var gpos : Lookup = parseLookup(1, data);
                gpos.posFormat.should.be(2);
                gpos.coverage.format.should.be(1);
                gpos.coverage.glyphs.should.containExactly([0x4f, 0x125, 0x129]);
                gpos.values[0].xPlacement.should.be(50);
                gpos.values[0].xAdvance.should.be(50);
                gpos.values[1].xPlacement.should.be(25);
                gpos.values[1].xAdvance.should.be(25);
                gpos.values[2].xPlacement.should.be(10);
                gpos.values[2].xAdvance.should.be(10);
            });
        
            //// Lookup type 2 ////////////////////////////////////////////////////////
            it('can parse lookup2 PairPosFormat1', function() {
                // https://docs.microsoft.com/en-us/typography/opentype/spec/gpos#example-4-pairposformat1-subtable
                final data = '0001 001E 0004 0001 0002 000E 0016   0001 0059 FFE2 FFEC 0001 0059 FFD8 FFE7   0001 0002 002D 0031';
                
                var lu2 : Lookup = parseLookup(2, data);
                lu2.posFormat.should.be(1);
                lu2.coverage.format.should.be(1);
                lu2.coverage.glyphs.should.containExactly([0x2d, 0x31]);
                lu2.valueFormat1.should.be(4);
                lu2.valueFormat2.should.be(1);
                lu2.pairSets[0][0].secondGlyph.should.be(0x59);
                lu2.pairSets[0][0].value1.xAdvance.should.be(-30);
                lu2.pairSets[0][0].value2.xPlacement.should.be(-20);
                lu2.pairSets[1][0].secondGlyph.should.be(0x59);
                lu2.pairSets[1][0].value1.xAdvance.should.be(-40);
                lu2.pairSets[1][0].value2.xPlacement.should.be(-25);
            });
        
            it('can parse lookup2 PairPosFormat2', function() {
                // https://docs.microsoft.com/en-us/typography/opentype/spec/gpos#example-5-pairposformat2-subtable
                final data = '0002 0018 0004 0000 0022 0032 0002 0002 0000 0000 0000 FFCE   0001 0003 0046 0047 0049   0002 0002 0046 0047 0001 0049 0049 0001   0002 0001 006A 006B 0001';
                var lu2 : Lookup = parseLookup(2, data);
                lu2.posFormat.should.be(2);
                lu2.coverage.format.should.be(1);
                lu2.coverage.glyphs.should.containExactly([0x46, 0x47, 0x49]);
                lu2.valueFormat1.should.be(4);
                lu2.valueFormat2.should.be(0);
                lu2.classDef1.format.should.be(2);
                lu2.classDef1.ranges[0].start.should.be(0x46);
                lu2.classDef1.ranges[0].end.should.be(0x47);
                lu2.classDef1.ranges[0].value.should.be(1);
                lu2.classDef1.ranges[1].start.should.be(0x49);
                lu2.classDef1.ranges[1].end.should.be(0x49);
                lu2.classDef1.ranges[1].value.should.be(1);
                lu2.classDef2.format.should.be(2);
                lu2.classDef2.ranges[0].start.should.be(0x6a);
                lu2.classDef2.ranges[0].end.should.be(0x6b);
                lu2.classDef2.ranges[0].value.should.be(1);
                lu2.classCount1.should.be(2);
                lu2.classCount2.should.be(2);
                lu2.classRecords[0][0].value1.xAdvance.should.be(0);
                lu2.classRecords[0][0].value2.should.be(null);
                lu2.classRecords[0][1].value1.xAdvance.should.be(0);
                lu2.classRecords[0][1].value2.should.be(null);
                lu2.classRecords[1][0].value1.xAdvance.should.be(0);
                lu2.classRecords[1][0].value2.should.be(null);
                lu2.classRecords[1][1].value1.xAdvance.should.be(-50);
                lu2.classRecords[1][1].value2.should.be(null);
            });
        });
    }
}