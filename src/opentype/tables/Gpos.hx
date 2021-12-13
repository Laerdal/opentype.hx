package opentype.tables;
import opentype.tables.Script;
import opentype.tables.subtables.Lookup;
import opentype.tables.subtables.Lookup.PairSet;
import haxe.io.Bytes;

class Gpos 
implements IScriptTable
implements ILayoutTable
{
    static function error(p) : Any {
        return null;
    }
    static var subtableParsers : Array<Parser -> Any> = [null, cast parseLookup1, cast parseLookup2, error, error, error, error, error, error, error];

    public function new() {
        //subtableParsers = [null, parseLookup2];         // subtableParsers[0] is unused
    }

    public var version(default, null) : Float = -1;
    public var scripts : Array<ScriptRecord> = [];
    public var lookups(default, null) : Array<LookupTable> = [];
    public var features(default, null) : Array<FeatureTable> = [];
    //features: p.parseFeatureList(),

    public static function parse(data : Bytes, position = 0) : Gpos {
        return parseGposTable(data, position);
    }

    // https://docs.microsoft.com/en-us/typography/opentype/spec/gpos#lookup-type-1-single-adjustment-positioning-subtable
    // this = Parser instance
    public static function parseLookup1(p: Parser) : Lookup {
        final start = p.offset + p.relativeOffset;
        final res = new Lookup();
        res.posFormat = p.parseUShort();
        Check.assert(res.posFormat == 1 || res.posFormat == 2, '${StringTools.hex(start)} : GPOS lookup type 1 format must be 1 or 2.');
        res.coverage = p.parsePointer().parseCoverage();
        if (res.posFormat == 1) {
            res.value = p.parseValueRecord();
        } else if (res.posFormat == 2) {
            res.values = p.parseValueRecordList();
        }
        return res;
    };


    // https://docs.microsoft.com/en-us/typography/opentype/spec/gpos#lookup-type-2-pair-adjustment-positioning-subtable
    static function parseLookup2(p : Parser) : Lookup {
        final start = p.offset + p.relativeOffset;
        final res = new Lookup();
        res.posFormat = p.parseUShort();
        Check.assert(res.posFormat == 1 || res.posFormat == 2, '${StringTools.hex(start)} + : GPOS lookup type 2 format must be 1 or 2.');
        res.coverage = p.parsePointer().parseCoverage();
        res.valueFormat1 = p.parseUShort();
        res.valueFormat2 = p.parseUShort();
        if (res.posFormat == 1) {
            // Adjustments for Glyph Pairs
            res.pairSets = p.parseList(() -> p.parseAtPointer(
                p -> p.parseList(() -> new PairSet(
                        p.parseUShort(),
                        p.parseValueRecordOfFormat(res.valueFormat1),
                        p.parseValueRecordOfFormat(res.valueFormat2)
                    )
                )
            ));
        } else if (res.posFormat == 2) {
            res.classDef1 = p.parseAtPointer(Parser.classDef);
            res.classDef2 = p.parseAtPointer(Parser.classDef);
            res.classCount1 = p.parseUShort();
            res.classCount2 = p.parseUShort();
            res.classRecords = p.parseListOfLength(res.classCount1, () -> {
                p.parseListOfLength(res.classCount2, () -> {
                    var r : Pair<ValueRecord, ValueRecord> = {
                        value1 : p.parseValueRecordOfFormat(res.valueFormat1),
                        value2 : p.parseValueRecordOfFormat(res.valueFormat2)
                    };
                    return r;
                });
            });
        }
       // Check.assert(false, '${StringTools.hex(start)} : GPOS lookup type 1 format must be 1 or 2.');
        return res;
    }


    // https://docs.microsoft.com/en-us/typography/opentype/spec/gpos
    static function parseGposTable(data : Bytes, start = 0) : Gpos {
        final p = new Parser(data, start);
        final tableVersion = p.parseVersion(1);
        if(tableVersion != 1 && tableVersion != 1.1) throw('Unsupported GPOS table version ' + tableVersion);
        var gpos = new Gpos();
        gpos.version = tableVersion;
        gpos.scripts = p.parseScriptList();
        gpos.features = p.parseFeatureList();
        gpos.lookups = p.parseLookupList(subtableParsers);
        if(tableVersion != 1) {
            //gpos.variations = p.parseFeatureVariationsList()
        }
        return gpos;
    }
}