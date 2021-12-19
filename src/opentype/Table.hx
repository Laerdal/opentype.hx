package opentype;

import opentype.tables.ScriptRecord;
import opentype.tables.LangSysRecord;

class Table {
    public var tableName : String;
    public var fields(default, null) : Map<String, Field> = [];
    public function new(tableName : String, tableFields : Array<Field>, ?options : Any) {
        // For coverage tables with coverage format 2, we do not want to add the coverage data directly to the table object,
        // as this will result in wrong encoding order of the coverage data on serialization to bytes.
        // The fallback of using the field values directly when not present on the table is handled in types.encode.TABLE() already.
        if (tableFields != null && (tableFields[0].name != 'coverageFormat' || tableFields[0].value == 1)) {
            for (i in  0...tableFields.length) {
                final field = tableFields[i];
                fields[field.name] = field.value;
            }
        }

        this.tableName = tableName;
        for (i in  0...tableFields.length) {
            final field = tableFields[i];
            fields[field.name] = field;
        }
/*
        this.fields = fields;
        if (options) {
            const optionKeys = Object.keys(options);
            for (let i = 0; i < optionKeys.length; i += 1) {
                const k = optionKeys[i];
                const v = options[k];
                if (this[k] !== undefined) {
                    this[k] = v;
                }
            }
        }
        */      
    }

    public function encode() {
        return Types.encodeTable(this);
    }
}



class ScriptList 
extends Table {
    public function new(scriptListTable : Array<Any>) {
        super('scriptListTable',
            TableUtil.recordList('scriptRecord', scriptListTable, cast function(scriptRecord : ScriptRecord, i : Int)  : Array<Field>{
                final script = scriptRecord.script;
                var defaultLangSys = script.defaultLangSys;
                Check.assert(defaultLangSys != null, 'Unable to write GSUB: script ' + scriptRecord.tag + ' has no default language system.');
                return [
                    new Field('scriptTag$i', 'TAG', scriptRecord.tag),
                    new Field('script$i', 'TABLE', new Table('scriptTable', [
                        new Field('defaultLangSys', 'TABLE', new Table('defaultLangSys', [
                            new Field('lookupOrder', 'USHORT', 0),
                            new Field('reqFeatureIndex', 'USHORT', defaultLangSys.reqFeatureIndex)]
                            .concat( TableUtil.ushortList('featureIndex', defaultLangSys.featureIndexes))))
                        ].concat(TableUtil.recordList('langSys', cast script.langSysRecords, cast function(langSysRecord : LangSysRecord, i) {
                            final langSys = langSysRecord.langSys;
                            return [
                                new Field('langSysTag$i', 'TAG', langSysRecord.tag),
                                new Field('langSys$i', 'TABLE', new Table('langSys', [
                                    new Field('lookupOrder', 'USHORT', 0),
                                    new Field('reqFeatureIndex', 'USHORT', langSys.reqFeatureIndex)
                                    ].concat(TableUtil.ushortList('featureIndex', langSys.featureIndexes)))
                                )
                            ];
                        }))
                        )
                    )
                ];
            })
        );
    }
}



@:structInit
class Field {
    public function new(name : String, type : String, value : Any) {
        this.name = name;
        this.type = type;
        this.value = value;
    }
    public var name(default, null) : String;
    public var type(default, null) : String;
    public var value(default, null) : Any;
}

class TableUtil {
    public static function recordList(itemName : String, records : Array<Any>, itemCallback : Any -> Int -> Array<Field>) : Array<Field> {
        final count = records.length;
        var fields : Array<Field> = [];
        fields.push({name: itemName + 'Count', type: 'USHORT', value: count});
        for (i in 0...count) {
            fields = fields.concat(itemCallback(records[i], i));
        }
        return fields;
    }
    
    public static function ushortList(itemName : String, list : Array<Int>, ?count : Int) : Array<Field> {
       if (count == null) {
           count = list.length;
       }
       final fields : Array<Field> = [{name: itemName + 'Count', type: 'USHORT', value: count}];
       for (i in 0...list.length) {
           fields.push({name: itemName + i, type: 'USHORT', value: list[i]});
       }
       return fields;
   }    
}