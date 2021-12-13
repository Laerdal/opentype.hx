package opentype;

import opentype.tables.FeatureTable; 
import opentype.tables.FeatureTable.Feature; 
import opentype.tables.LangSys; 
import opentype.tables.LangSysRecord;
import opentype.tables.LookupTable;
import opentype.tables.ScriptRecord;
import opentype.tables.Script; 
import opentype.tables.ValueRecord; 
import opentype.tables.subtables.Coverage;
import opentype.tables.subtables.RangeRecord;
import opentype.tables.subtables.ClassDefinition;
import opentype.tables.subtables.Lookup;
import haxe.io.Bytes;
using opentype.BytesHelper;

typedef Uint8  = Int;
typedef Int8   = Int;
typedef Uint16 = Int;
typedef Int16  = Int;
typedef Uint32 = Int;
typedef Int32  = Int;

class Parser {

    public static final typeOffsetByte = 1;
    public static final typeOffsetUShort = 2;
    public static final typeOffsetShort = 2;
    public static final typeOffsetULong = 4;
    public static final typeOffsetFixed = 4;
    public static final typeOffsetLongDateTime = 8;
    public static final typeOffsetTag = 4;    

    public function new(data : Bytes, offset = 0) {
        this.data = data;
        this.offset = offset;
        this.relativeOffset = 0;
    }

    public static function byte(p : Parser) : Int return p.parseByte();
    public function parseByte() : Int {
        return data.readU8(offset + relativeOffset++);
    };

    public static function char(p : Parser) : Int return p.parseChar();
    public function parseChar() : Int {
		return data.readChar(offset + relativeOffset++);
    };    
        
    public static function uShort(p: Parser) : Int return p.parseUShort();
	public function parseUShort(): Int {
        final v = data.readU16BE(offset + relativeOffset);
        relativeOffset += 2;
        return v; 
	}

    public static function short(p: Parser) : Int return p.parseShort();
    public function parseShort() : Int {
        final v = data.readS16BE(offset + relativeOffset);
        relativeOffset += 2;
        return v;
    };

    public function parseULong() {
        final v = data.readULong(offset + relativeOffset);
        relativeOffset += 4;
        return v;
    };    

    public function parseFixed() {
        final v = data.getFixed(offset + relativeOffset);
        relativeOffset += 4;
        return v;
    };

    public function parseString(length : Int) {
        final offset = offset + relativeOffset;
        var string = '';
        for (i in 0...length) {
            string += String.fromCharCode(data.readU8(offset + i));
        }
        relativeOffset += length;
        return string;
    };    

    public static function tag(p : Parser) : String {
        return p.parseTag();
    }
    public function parseTag() {
        return this.parseString(4);
    };

    // LONGDATETIME is a 64-bit integer.
    // JavaScript and unix timestamps traditionally use 32 bits, so we
    // only take the last 32 bits.
    // + Since until 2038 those bits will be filled by zeros we can ignore them.
    public function parseLongDateTime() {
        var v = data.readULong(offset + relativeOffset + 4);
        // Subtract seconds between 01/01/1904 and 01/01/1970
        // to convert Apple Mac timestamp to Standard Unix timestamp
        v -= 2082844800;
        relativeOffset += 8;
        return v;
    };

    public function parseVersion(minorBase = 0x1000) : Float {
        final major = BytesHelper.readU16BE(this.data, this.offset + this.relativeOffset);
    
        // How to interpret the minor version is very vague in the spec. 0x5000 is 5, 0x1000 is 1
        // Default returns the correct number if minor = 0xN000 where N is 0-9
        // Set minorBase to 1 for tables that use minor = N where N is 0-9
        final minor = BytesHelper.readU16BE(this.data, this.offset + this.relativeOffset + 2);
        this.relativeOffset += 4;
        return major + minor / minorBase / 10;
    };    
    
    public function skip(offset : Int, amount = 1) : Void {
        relativeOffset += offset * amount;
    };

    public function skipULong(amount = 1) : Void { 
        skip(typeOffsetULong, amount);
    }
    public function skipUShort(amount = 1) : Void { 
        skip(typeOffsetUShort, amount);
    }

    // Parse a list of 16 bit unsigned integers. The length of the list is read on the stream
    public static function uShortList(p : Parser) : Array<Int> {
        return p.parseUShortList();
    }
    public function parseUShortList() : Array<Int> {
        return parseUShortListOfLength(parseUShort());
    }
    public function parseUShortListOfLength(count : Int) : Array<Int> {
        return [ for(i in 0...count) parseUShort() ];
    }


    /**
    * Parse a list of items.
    * Record count is optional, if omitted it is read from the stream.
    * itemCallback is one of the Parser methods.
    */
    /* might not be needed
    public static function list<T>(p : Parser, parseFn : Void -> T) : Array<T> { 
        return p.parseList(parseFn); 
    }
    public static function listOfLength<T>(p : Parser, count : Int, parseFn : Void -> T) : Array<T> { 
        return p.parseListOfLength(count, parseFn); 
    }
    */
    public function parseList<T>(parseFn : Void -> T) : Array<T> {
        return parseListOfLength(parseUShort(), parseFn);
    };
    public function parseListOfLength<T>(count : Int, parseFn : Void -> T) : Array<T> {
        return [for (i in 0...count) parseFn()];
    };

    /**
    * Parse a list of records.
    * Record count is optional, if omitted it is read from the stream.
    * Example of recordDescription: { sequenceIndex: Parser.uShort, lookupListIndex: Parser.uShort }
    */
    public static function recordListOfLength<T>(p : Parser, count : Int, recordDescription : Array<RecordDescription<T>>) : Array<Array<Record<T>>> {
        return p.parseRecordListOfLength(count, recordDescription);
    } 
    public function parseRecordListOfLength<T>(count : Int, recordDescription : Array<RecordDescription<T>>) : Array<Array<Record<T>>> 
    {
        // If the count argument is absent, read it in the stream.
        final records = new Array<Array<Record<T>>>();
        records.resize(count);
        for (i in 0...count) {
            var pairs = [];
            for(f in recordDescription) {
                final rec : Record<T> = { 
                    name : f.name,
                    value : f.parseFn(this)
                };
                pairs.push(rec);
            }
            records[i] = pairs;
        }
        return records;
    }

    public static function recordList<T>(recordDescription : Array<RecordDescription<T>>) : Parser -> Array<Array<Record<T>>> {
        return p -> p.parseRecordList(recordDescription);
    }
    public function parseRecordList<T>(recordDescription : Array<RecordDescription<T>>) : Array<Array<Record<T>>> {
        return parseRecordListOfLength(parseUShort(), recordDescription);
    }

    /**
    * Parse a list of records.
    * Record count is optional, if omitted it is read from the stream.
    */
    public function parseRecordListOfSameType<T>(names : Array<String>, valueParser : Parser -> T ) : Array<Array<Record<T>>> 
    {
        return parseRecordList([for(name in names) { name : name, parseFn : valueParser } ]);
    }




    /**
    * Parse a GPOS valueRecord
    * https://docs.microsoft.com/en-us/typography/opentype/spec/gpos#value-record
    * valueFormat is optional, if omitted it is read from the stream.
    */
    public function parseValueRecord() : ValueRecord {
        return parseValueRecordOfFormat(parseUShort());
    }

    public function parseValueRecordOfFormat(valueFormat : Int) : ValueRecord {
        if (valueFormat == 0) {
            // valueFormat2 in kerning pairs is most often 0
            // in this case return undefined instead of an empty object, to save space
            return null;
        }
        final valueRecord = new ValueRecord();
        if (valueFormat & 0x0001 != 0) { valueRecord.xPlacement = parseShort(); }
        if (valueFormat & 0x0002 != 0) { valueRecord.yPlacement = parseShort(); }
        if (valueFormat & 0x0004 != 0) { valueRecord.xAdvance = parseShort(); }
        if (valueFormat & 0x0008 != 0) { valueRecord.yAdvance = parseShort(); }
        // Device table (non-variable font) / VariationIndex table (variable font) not supported
        // https://docs.microsoft.com/fr-fr/typography/opentype/spec/chapter2#devVarIdxTbls
        if (valueFormat & 0x0010 != 0) { /* valueRecord.xPlaDevice = ?*/ parseShort(); }
        if (valueFormat & 0x0020 != 0) { /* valueRecord.yPlaDevice = ?*/ parseShort(); }
        if (valueFormat & 0x0040 != 0) { /* valueRecord.xAdvDevice = ?*/ parseShort(); }
        if (valueFormat & 0x0080 != 0) { /* valueRecord.yAdvDevice = ?*/ parseShort(); }
        
        return valueRecord;
    }

    /**
    * Parse a list of GPOS valueRecords
    * https://docs.microsoft.com/en-us/typography/opentype/spec/gpos#value-record
    * valueFormat and valueCount are read from the stream.
    */
    public function parseValueRecordList() : Array<ValueRecord>{
        final valueFormat = parseUShort();
        final valueCount = parseUShort();
        return [for(i in 0...valueCount) parseValueRecordOfFormat(valueFormat)];
    };    



    public function parsePointer() : Parser {
        final pointerOffset = parseUShort();
        if (pointerOffset > 0) {
            return new Parser(data, offset + pointerOffset);
        }
        return null;
    };

    /**
    * Parse a list of offsets to lists of 16-bit integers,
    * or a list of offsets to lists of offsets to any kind of items.
    * If itemCallback is not provided, a list of list of UShort is assumed.
    * If provided, itemCallback is called on each item and must parse the item.
    * See examples in tables/gsub.js
    */
    public function parseListOfLists<T>(itemCallback : Void -> T) : Array<Array<T>> {
        final offsets = parseUShortList();
        final count = offsets.length;
        final relativeOffset = this.relativeOffset;
        final list = new Array();
        list.resize(count);
        for (i in 0...count) {
            final start = offsets[i];
            if (start == 0) {
                // NULL offset
                // Add null to list. Convenient with assert.
                list[i] = null;
                continue;
            }
            this.relativeOffset = start;            
            final subOffsets = parseUShortList();
            final subList = new Array();
            subList.resize(subOffsets.length);
            final subList = [for (j in 0...subOffsets.length) {
                this.relativeOffset = start + subOffsets[j];
                subList[j] = itemCallback();
            }];
            list[i] = subList;
        }
        this.relativeOffset = relativeOffset;
        return list;
    };

    /**
    * Parse a list of offsets to lists of 16-bit integers,
    */
    public function parseListOfListsOfUShort() : Array<Array<Int>> {
        final offsets = parseUShortList();
        final relativeOffset = this.relativeOffset;
        final list = [
            for (i in 0...offsets.length) {
                this.relativeOffset = offsets[i];            
                parseUShortList();
            }
        ];
        this.relativeOffset = relativeOffset;
        return list;
    };




    ///// Complex tables parsing //////////////////////////////////

    // Parse a coverage table in a GSUB, GPOS or GDEF table.
    // https://www.microsoft.com/typography/OTSPEC/chapter2.htm
    // parser.offset must point to the start of the table containing the coverage.
    public static function coverage(parser : Parser) : Coverage { return parser.parseCoverage(); }
    public function parseCoverage() : Coverage {
        final startOffset = offset + relativeOffset;
        final format = parseUShort();
        final count = parseUShort();
        if (format == 1) {
            return {
                format: 1,
                glyphs: parseUShortListOfLength(count),
                ranges: []
            };
        } else if (format == 2) {
            return {
                format: 2,
                ranges: [ for (i in 0...count) { start: parseUShort(), end: parseUShort(), value: parseUShort() } ],
                glyphs: []
            };
        }
        throw('${StringTools.hex(startOffset)}: Coverage format must be 1 or 2.');
    };


    // Parse a Class Definition Table in a GSUB, GPOS or GDEF table.
    // https://www.microsoft.com/typography/OTSPEC/chapter2.htm
    public static function classDef(p : Parser) : ClassDefinition { return p.parseClassDef(); }
    public function parseClassDef() : ClassDefinition {
        final startOffset = this.offset + this.relativeOffset;
        final format = parseUShort();
        if (format == 1) {
            return {
                format: 1,
                startGlyph : parseUShort(),
                classes: parseUShortList()
            };
        } else if (format == 2) {
            var recordList = parseRecordListOfSameType(["start", "end", "classId"], uShort);
            return {
                format: 2,
                ranges: [ for(r in recordList) { start : r[0].value, end: r[1].value, value: r[2].value} ]
            };
        }
        throw('${StringTools.hex(startOffset)}: ClassDef format must be 1 or 2.');
    };

    public function parseScriptList() : Array<ScriptRecord> {
        var p = parsePointer();
        return if(p != null) {
            p.parseElements(p -> new ScriptRecord(
                p.parseTag(),
                p.parseAtPointer(p -> new Script(
                    p.parseAtPointer(p -> new LangSys(
                        p.parseUShort(),
                        p.parseUShort(),
                        p.parseUShortList()
                    )),
                    p.parseElements(p -> new LangSysRecord(
                        p.parseTag(), 
                        p.parseAtPointer(p -> new LangSys(
                            p.parseUShort(),
                            p.parseUShort(),
                            p.parseUShortList()
                        ))
                    ))
                ))
            ));
        } else [];
    }

    function parseElements<T>(parseFn : Parser -> T) : Array<T> {
        return parseNElements(parseUShort(), parseFn);
    }
    
    function parseNElements<T>(count : Int, parseFn : Parser -> T) : Array<T> {
        return [for(c in 0...count) parseFn(this) ];
    }

    //Features
    public function parseFeatureList() : Array<FeatureTable> {
        var p = parsePointer();
        return p != null ? p.parseElements(featureTable) : [];
    }

    function featureTable(p : Parser) : FeatureTable {
        return new FeatureTable(
            p.parseTag(),
            p.parseAtPointer(feature)
        );
    }

    function feature(p : Parser) : Feature {
        return new Feature(
            p.parseUShort(),
            p.parseUShortList()
        );
    }

    public function parseAtPointer<T>(parseFn : Parser -> T) : T {
        var p = parsePointer();
        return (p != null) ? parseFn(p) : null;
    };

    public function parseLookupList<T>(lookupTableParsers : Array<Parser -> Any>) : Array<LookupTable> {
        var p = parsePointer();
        if(p == null) return [];

        return p.parseList(() -> {
            p.parseAtPointer((p) -> {
                final lookupType = p.parseUShort();
                Check.assert(1 <= lookupType && lookupType <= 9, 'GPOS/GSUB lookup type ' + lookupType + ' unknown.');
                final lookupFlag = p.parseUShort();
                final useMarkFilteringSet = lookupFlag & 0x10;
                return new LookupTable(
                    lookupType, 
                    lookupFlag, 
                    p.parseList(() -> p.parseAtPointer(lookupTableParsers[lookupType] )),
                    useMarkFilteringSet > 0 ? p.parseUShort() : useMarkFilteringSet
                );
            });
        });
    };

    // Retrieve a 4-character tag from the Bytes data.
    // Tags are used to identify tables.
    public static function getTag(data : Bytes, offset : Int) : String {
        var tag = '';
        for (i in offset...offset + 4) {
            tag += String.fromCharCode(data.readChar(i));
        }
        return tag;
    }

    var data : Bytes;
    public var offset(default, null) : Int;
    public var relativeOffset(default, null) : Int;
}

@:structInit
class Record<T> { 
    public function new(
        name : String,
        value : T
    ) {
        this.name = name;
        this.value = value;
    }
    
    public var name : String;
    public var value : T; 
}

@:structInit
class RecordDescription<T> { 
    public function new(
        name : String,
        parseFn : Parser -> T
    ) {
        this.name = name;
        this.parseFn = parseFn;
    }
    
    public var name : String;
    public var parseFn : Parser -> T; 
}
