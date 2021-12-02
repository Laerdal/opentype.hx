package opentype;

import opentype.tables.LookupTable;
import opentype.tables.subtables.Coverage;
import opentype.tables.subtables.RangeRecord;
import opentype.tables.subtables.ClassDefinition;
import opentype.tables.subtables.ClassRangeRecord;
import haxe.io.Bytes;
using opentype.BytesHelper;

typedef Uint8  = Int;
typedef Int8   = Int;
typedef Uint16 = Int;
typedef Int16  = Int;
typedef Uint32 = Int;
typedef Int32  = Int;


class Parser {
    public function new(data : Bytes, offset : Int) {
        this.data = data;
        this.offset = offset;
        this.relativeOffset = 0;
    }

    public function parserFromOffset(offset) : Parser {
        return new Parser(data, this.offset + offset);
    }

    public static function byte(p : Parser) : Int return p.parseByte();
    public function parseByte() : Int {
        return data.readU8(offset + relativeOffset++);
    };

    public static function char(p : Parser) : Int return p.parseChar();
    public function parseChar() : Int {
		return data.readChar(offset + relativeOffset++);
    };    
        
    public static function uShort(p : Parser) : Int return p.parseUShort();
	public function parseUShort(): Int {
        final v = data.readU16BE(offset + relativeOffset);
        relativeOffset += 2;
        return v; 
	}
/*
    public function parseULong() {
        final v = getULong(this.data, this.offset + this.relativeOffset);
        this.relativeOffset += 4;
        return v;
    };    

    public function parseFixed() {
        final v = getFixed(this.data, this.offset + this.relativeOffset);
        this.relativeOffset += 4;
        return v;
    };
*/

    public function parseString(length : Int) {
        final offset = this.offset + this.relativeOffset;
        var string = '';
        for (i in 0...length) {
            string += String.fromCharCode(data.readU8(offset + i));
        }
        relativeOffset += length;
    
        return string;
    };    

    public function parseTag() {
        return this.parseString(4);
    };

    public function parseVersion(minorBase : Int) {
        final major = BytesHelper.readU16BE(this.data, this.offset + this.relativeOffset);
    
        // How to interpret the minor version is very vague in the spec. 0x5000 is 5, 0x1000 is 1
        // Default returns the correct number if minor = 0xN000 where N is 0-9
        // Set minorBase to 1 for tables that use minor = N where N is 0-9
        final minor = BytesHelper.readU16BE(this.data, this.offset + this.relativeOffset + 2);
        this.relativeOffset += 4;
        if (minorBase == null) minorBase = 0x1000;
        return Std.int(major + minor / minorBase / 10);
    };    

    // Parse a list of 16 bit unsigned integers. The length of the list can be read on the stream
    // or provided as an argument.
    public function parseUShortList(?count : Int) : Array<Int> {
        if (count == null) count = parseUShort();
        return [ for(i in 0...count) parseUShort() ];
    }

    /**
    * Parse a list of items.
    * Record count is optional, if omitted it is read from the stream.
    * itemCallback is one of the Parser methods.
    */
    public static function list<T>(parser : Parser, ?count : Int, itemCallback : Void -> T) : Array<T> { return parser.parseList(count, itemCallback); }
    public function parseList<T>(?count : Int, itemCallback : Void -> T) : Array<T> {
        if (count == null) count = parseUShort();
        return [for (i in 0...count) itemCallback()];
    };

    /**
    * Parse a list of records.
    * Record count is optional, if omitted it is read from the stream.
    * Example of recordDescription: { sequenceIndex: Parser.uShort, lookupListIndex: Parser.uShort }
    */
    public function parseRecordList(?count : Int, recordDescription : Array<RecordDescription>) : Array<Array<Pair<String, Int>>> 
    {
        // If the count argument is absent, read it in the stream.
        if (count == null) count = parseUShort();
        final records = new Array<Array<Pair<String, Int>>>();
        records.resize(count);
        for (i in 0...count) {
            var pairs = [];
            for(f in recordDescription) {
                final rec : Pair<String, Int> = { 
                    name : f.name,
                    value : f.parseFn()
                };
                pairs.push(rec);
            }
            records[i] = pairs;
        }
        return records;
    }

    /**
    * Parse a list of records.
    * Record count is optional, if omitted it is read from the stream.
    */
    public function parseRecordListOfSameType(?count : Int, names : Array<String>, valueParser : Void -> Int ) : Array<Array<Pair<String, Int>>> 
    {
        return parseRecordList(count, [for(name in names) { name : name, parseFn : valueParser } ]);
    }

    // Parse a data structure into an object
    // Example of description: { sequenceIndex: Parser.uShort, lookupListIndex: Parser.uShort }
/*
    public function parseStruct(description) {
        if (typeof description === 'function') {
            return description.call(this);
        } else {
            final fields = Object.keys(description);
            final struct = {};
            for (let j = 0; j < fields.length; j++) {
                final fieldName = fields[j];
                final fieldType = description[fieldName];
                struct[fieldName] = fieldType.call(this);
            }
            return struct;
        }
    };
*/
/*
    public function parsePointer<T>(parseFn : Parser -> T) {
        final structOffset = parseUShort();
        if (structOffset > 0) {
            return parseFn(new Parser(data, offset + structOffset));
        }
        return null;
    };
    */

    public function parsePointer() : Parser {
        final structOffset = parseUShort();
        if (structOffset > 0) {
            return new Parser(data, offset + structOffset);
        }
        return null;
    };


    /*
    public function parsePointer32(description) {
        final structOffset = parseOffset32();
        if (structOffset > 0) {
            // NULL offset => return undefined
            return new Parser(data, offset + structOffset).parseStruct(description);
        }
        return undefined;
    };
    */

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
                glyphs: parseUShortList(count),
                ranges: []
            };
        } else if (format == 2) {
            return {
                format: 2,
                ranges: [ for (i in 0...count) { startGlyphId: parseUShort(), endGlyphId: parseUShort(), startCoverageIndex: parseUShort() } ],
                glyphs: []
            };
        }
        throw('${StringTools.hex(startOffset)}: Coverage format must be 1 or 2.');
    };


    // Parse a Class Definition Table in a GSUB, GPOS or GDEF table.
    // https://www.microsoft.com/typography/OTSPEC/chapter2.htm
    public function parseClassDef() : ClassDefinition {
        final startOffset = this.offset + this.relativeOffset;
        final format = parseUShort();
        if (format == 1) {
            return {
                format: 1,
                startGlyphId : parseUShort(),
                classValueArray: parseUShortList()
            };
        } else if (format == 2) {
            var recordList = parseRecordListOfSameType(["start", "end", "classId"], parseUShort);
            return {
                format: 2,
                classRangeRecords: [ for(r in recordList) { startGlyphId : r[0].value, endGlyphId: r[1].value, classId: r[2].value} ]
            };
        }
        throw('${StringTools.hex(startOffset)}: ClassDef format must be 1 or 2.');
    };
/* probably not needed
    public function parseScriptList() {
        final langSysTable = [
            { name : "reserved", parseFn : parseUShort },
            { name : "reqFeatureIndex", parseFn : parseUShort },
            { name : "featureIndexes", parseFn : parseUShortList }
        ];
        
        var res = parsePointer(parseRecordList(
            [
                { name : "tag", parseFn : parseTag },
                
                { name : "script", parseFn : parsePointer([
                        { name : "defaultLangSys", parseFn : parsePointer(langSysTable) },
                        { name : "langSysRecords", parseFn : parseRecordList([ { name : "tag", parseFn : parseTag }, { name : "langSys", parseFn : parsePointer(langSysTable) }]) }
                ]}
            ]
        ));

            var res = parsePointer(parseRecordList({
            tag: parseTag,
            script: parsePointer({
                defaultLangSys: parsePointer(langSysTable),
                langSysRecords: parseRecordList({
                    tag: parseTag,
                    langSys: parsePointer(langSysTable)
                })
            })
        }));
        return res != null ? res : [];
    };  
*/
    public function parseLookupList<T>(lookupTableParsers : Array<Parser -> Any>) : Array<LookupTable> {
        var p = parsePointer();
        var offSets = p.parseList(p.parseUShort);
        var res : Array<LookupTable> = [];
        for(o in offSets) {
            var po = p.parserFromOffset(o);
            final lookupType = p.parseUShort();
            Check.assert(1 <= lookupType && lookupType <= 9, 'GPOS/GSUB lookup type ' + lookupType + ' unknown.');
            final lookupFlag = p.parseUShort();
            var subTablesOffSets = p.parseList(p.parseUShort);
            var subTables = [];
            for(st in subTablesOffSets) {
                var subtableParser = po.parserFromOffset(st);
                subTables.push(lookupTableParsers[lookupType](subtableParser));

            }
            res.push({
                lookupType: lookupType,
                lookupFlag: lookupFlag,
                subTables: subTables
            });
        }
        return res != null ? res : [];
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
class Pair<T,S> { 
    public function new(
        name : T,
        value : S
    ) {
        this.name = name;
        this.value = value;
    }
    
    public var name : T;
    public var value : S; 
}

@:structInit
class RecordDescription { 
    public function new(
        name : String,
        parseFn : Void -> Int
    ) {
        this.name = name;
        this.parseFn = parseFn;
    }
    
    public var name : String;
    public var parseFn : Void -> Int; 
}
