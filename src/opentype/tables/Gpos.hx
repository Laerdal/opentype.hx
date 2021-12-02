package opentype.tables;

import haxe.io.Bytes;

class Gpos {

    var subtableParsers : Array<Parser -> Void>;

    public function new() {
        subtableParsers = [null, parseLookup2];         // subtableParsers[0] is unused
    }

    public var version(default, null) : Int;
    //scripts: p.parseScriptList(),
    //features: p.parseFeatureList(),
    //public var lookups(default, null) :     

    public static function parse(data : Bytes, position : Int) : Gpos {
        return parseGposTable(data, position);
        
        //return new Gpos();
    }

    // https://docs.microsoft.com/en-us/typography/opentype/spec/gpos#lookup-type-2-pair-adjustment-positioning-subtable
    function parseLookup2(p : Parser) {
        final start = p.offset + p.relativeOffset;
        final posFormat = p.parseUShort();
        Check.assert(posFormat == 1 || posFormat == 2, '${StringTools.hex(start)} + : GPOS lookup type 2 format must be 1 or 2.');
        //final coverage = p.parsePointer(p.parseCoverage);
        //final valueFormat1 = p.parseUShort();
        //final valueFormat2 = p.parseUShort();
        /*
        if (posFormat == 1) {
            // Adjustments for Glyph Pairs
            return {
                posFormat: posFormat,
                coverage: coverage,
                valueFormat1: valueFormat1,
                valueFormat2: valueFormat2,
                pairSets: p.parseList(Parser.pointer(Parser.list(function() {
                    return {        // pairValueRecord
                        secondGlyph: p.parseUShort(),
                        value1: p.parseValueRecord(valueFormat1),
                        value2: p.parseValueRecord(valueFormat2)
                    };
                })))
            };
        } else if (posFormat == 2) {
            final classDef1 = this.parsePointer(Parser.classDef);
            final classDef2 = this.parsePointer(Parser.classDef);
            final class1Count = this.parseUShort();
            final class2Count = this.parseUShort();
            return {
                // Class Pair Adjustment
                posFormat: posFormat,
                coverage: coverage,
                valueFormat1: valueFormat1,
                valueFormat2: valueFormat2,
                classDef1: classDef1,
                classDef2: classDef2,
                class1Count: class1Count,
                class2Count: class2Count,
                classRecords: this.parseList(class1Count, Parser.list(class2Count, function() {
                    return {
                        value1: this.parseValueRecord(valueFormat1),
                        value2: this.parseValueRecord(valueFormat2)
                    };
                }))
            };
        }
        */
    }


    // https://docs.microsoft.com/en-us/typography/opentype/spec/gpos
    public static function parseGposTable(data : Bytes, start = 0) : Gpos {
        final p = new Parser(data, start);
        final tableVersion = p.parseVersion(1);
        if(tableVersion != 1 && tableVersion != 1.1) throw('Unsupported GPOS table version ' + tableVersion);
        
        var gpos = new Gpos();
        gpos.version = tableVersion;
        //gpos.lookups = p.parseLookupList(subtableParsers);
        //scripts: p.parseScriptList(),
        //features: p.parseFeatureList(),
        if(tableVersion != 1) {
            //gpos.variations = p.parseFeatureVariationsList()
        }
        return gpos;
    }
}