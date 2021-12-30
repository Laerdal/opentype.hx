package tables;

import haxe.io.Bytes;
using buddy.Should;
using opentype.BytesHelper;
import opentype.tables.Ltag; 
import opentype.Table; 
import opentype.Table.Field;
using TestUtil;

@:structInit
class NameTableEntry {
    public function new(nameId, text, platformId, encodingId, languageId) {
        this.nameId = nameId; 
        this.text = text; 
        this.platformId = platformId; 
        this.encodingId = encodingId; 
        this.languageId = languageId; 
    }

    public var nameId : Int; //0
    public var text : String; //1
    public var platformId : Int; //2
    public var encodingId : Int; //3
    public var languageId : Int; //4
}

class NameTable extends buddy.BuddySuite {
// For testing, we need a custom function that builds name tables.
// The public name.make() API of opentype.js is hiding the complexity
// of the various historic encodings and language identification
// systems that are used in OpenType and TrueType. Instead, it emits a
// simple JavaScript dictionary keyed by IETF BCP 47 language codes,
// which is the same format that is used for HTML and XML language
// tags.  That is convenient for users of opentype.js, but it
// complicates testing.
function makeNameTable(names : Array<NameTableEntry>) {
    final t = new opentype.Table('name', [
        {name: 'format', type: 'USHORT', value: 0},
        {name: 'count', type: 'USHORT', value: names.length},
        {name: 'stringOffset', type: 'USHORT', value: 6 + names.length * 12}
    ]);
    final stringPool = [];

    for (i in 0...names.length) {
        var name = names[i];
        final text = name.text.unhex();
        t.fieldsOrdered.push( new Field('platformID_' + i, 'USHORT', name.platformId));
        t.fieldsOrdered.push( new Field('encodingID_' + i, 'USHORT', name.encodingId));
        t.fieldsOrdered.push( new Field('languageID_' + i, 'USHORT', name.languageId));
        t.fieldsOrdered.push( new Field('nameID_' + i, 'USHORT', name.nameId));
        t.fieldsOrdered.push( new Field('length_' + i, 'USHORT', text.length));
        t.fieldsOrdered.push( new Field('offset_' + i, 'USHORT', stringPool.length));
        for (j in 0...text.length) {
            stringPool.push(text.readU8(j));
        }
    }

    t.fieldsOrdered.push( new Field('strings', 'LITERAL', stringPool));

    final bytes = opentype.Types.encodeTable(t);
    final data = Bytes.alloc(bytes.length);
    for (k in 0...bytes.length) {
        data.set(k, bytes[k]);
    }
    return data;
}    
    
    
    function parseNameTable(names : Array<NameTableEntry>, ltag) {
        return opentype.tables.Name.parse(makeNameTable(names), 0, ltag);
    }

    public function new() {
        describe('tables/Name.hx', {
            it('can parse a naming table', function() {
                var nameTable = parseNameTable([
                    new NameTableEntry(1, '0057 0061 006C 0072 0075 0073', 3, 1, 0x0409),
                    new NameTableEntry(1, '140A 1403 1555 1585', 3, 1, 0x045D),
                    new NameTableEntry(1, '0041 0069 0076 0069 0071', 3, 1, 0x085D),
                    new NameTableEntry(1, '6D77 99AC', 3, 1, 0x0411),
                    new NameTableEntry(300, '42 6C 61 63 6B 20 43 6F 6E 64 65 6E 73 65 64', 1, 0, 0),
                    new NameTableEntry(300, '4B 6F 79 75 20 53 DD 6B DD DF DD 6B', 1, 35, 17),
                    new NameTableEntry(300, '8F EE EB F3 F7 E5 F0 20 F2 E5 F1 E5 ED', 1, 7, 44),
                    new NameTableEntry(44444, '004C 0069 0070 0073 0074 0069 0063 006B 0020 D83D DC84', 3, 10, 0x0409)
                ], null);
                nameTable.properties['fontFamily']['en'].should.be('Walrus');
                nameTable.properties['fontFamily']['iu'].should.be('ᐊᐃᕕᖅ');
                nameTable.properties['fontFamily']['iu-Latn'].should.be('Aiviq');
                nameTable.properties['fontFamily']['ja'].should.be('海馬');
                nameTable.properties['300']['bg'].should.be('Получер тесен');
                nameTable.properties['300']['en'].should.be('Black Condensed');
                nameTable.properties['300']['tr'].should.be('Koyu Sıkışık');
                nameTable.properties['44444']['en'].should.be('Lipstick 💄');
                /*
                {
                    fontFamily: {
                        en: 'Walrus',
                        iu: 'ᐊᐃᕕᖅ',
                        'iu-Latn': 'Aiviq',
                        ja: '海馬'
                    },
                    300: {
                        bg: 'Получер тесен',
                        en: 'Black Condensed',
                        tr: 'Koyu Sıkışık'
                    },
                    44444: {
                        en: 'Lipstick 💄'
                    }
                });
                */
            });
            it('can parse a naming table which refers to an ‘ltag’ table', function() {
                final ltag = ['en', 'de', 'de-1901'];
                var nameTable = parseNameTable([
                    new NameTableEntry(1, '0057 0061 006C 0072 0075 0073', 0, 4, 0),
                    new NameTableEntry(1, '0057 0061 006C 0072 006F 0073 0073', 0, 4, 1),
                    new NameTableEntry(1, '0057 0061 006C 0072 006F 00DF', 0, 4, 2),
                    new NameTableEntry(999, '0057 0061 006C 0072 0075 0073 002D 0054 0068 0069 006E', 0, 4, 0xFFFF)
                ], ltag);

                nameTable.properties['fontFamily']['de'].should.be('Walross');
                nameTable.properties['fontFamily']['de-1901'].should.be('Walroß');
                nameTable.properties['fontFamily']['en'].should.be('Walrus');
                nameTable.properties['999']['und'].should.be('Walrus-Thin');
                /*
                {
                    fontFamily: {
                        de: 'Walross',
                        'de-1901': 'Walroß',
                        en: 'Walrus'
                    },
                    999: {
                        und: 'Walrus-Thin'
                    }
                }
                */
            });
            it('ignores name records for unknown platforms', {
                var nameTable = parseNameTable([
                    new NameTableEntry(1, '01 02', 666, 1, 1)
                ], null);
                Lambda.count(nameTable.properties).should.be(0);
            });
        /*
            it('can make a naming table', function() {
                // This is an interesting test case for various reasons:
                // * Indonesian ('id') uses the same string as English,
                //   so we exercise the building of string pools;
                const names = {
                    fontFamily: {
                        en: 'Walrus',
                        de: 'Walross',
                        id: 'Walrus'
                    }
                };
                const ltag = [];
                assert.deepEqual(getNameRecords(_name.make(names, ltag)), [
                    'Mac smRoman langEnglish N1 [57 61 6C 72 75 73]',
                    'Mac smRoman langGerman N1 [57 61 6C 72 6F 73 73]',
                    'Mac smRoman langIndonesian N1 [57 61 6C 72 75 73]',
                    'Win UCS-2 German/Germany N1 [00 57 00 61 00 6C 00 72 00 6F 00 73 00 73]',
                    'Win UCS-2 English/US N1 [00 57 00 61 00 6C 00 72 00 75 00 73]',
                    'Win UCS-2 Indonesian/Indonesia N1 [00 57 00 61 00 6C 00 72 00 75 00 73]'
                ]);
                assert.deepEqual(ltag, []);
            });
        
            it('can make a naming table that refers to a language tag table', function() {
                // Neither Windows nor MacOS define a numeric language code
                // for “German in the traditional orthography” (de-1901).
                // Windows has one for “Inuktitut in Latin” (iu-Latn),
                // but MacOS does not.
                const names = {
                    fontFamily: {
                        'de-1901': 'Walroß',
                        'iu-Latn': 'Aiviq'
                    }
                };
                const ltag = [];
                assert.deepEqual(getNameRecords(_name.make(names, ltag)), [
                    'Uni UTF-16 0 N1 [00 57 00 61 00 6C 00 72 00 6F 00 DF]',
                    'Uni UTF-16 1 N1 [00 41 00 69 00 76 00 69 00 71]',
                    'Win UCS-2 Inuktitut-Latin/Canada N1 [00 41 00 69 00 76 00 69 00 71]'
                ]);
                assert.deepEqual(ltag, ['de-1901', 'iu-Latn']);
            });
        
            it('can make a naming table for languages in unsupported scripts', function() {
                // MacJapanese would need very large tables for conversion,
                // so we do not ship a codec for this encoding in opentype.js.
                // The implementation should fall back to emitting Unicode strings
                // with a BCP 47 language code; only newer versions of MacOS will
                // recognize it but this is better than stripping the string away.
                const names = {
                    fontFamily: {
                        ja: '海馬'
                    }
                };
                const ltag = [];
                assert.deepEqual(getNameRecords(_name.make(names, ltag)), [
                    'Uni UTF-16 0 N1 [6D 77 99 AC]',
                    'Win UCS-2 Japanese/Japan N1 [6D 77 99 AC]'
                ]);
                assert.deepEqual(ltag, ['ja']);
            });
        
            it('can make a naming table for English names with unusual characters', function() {
                // The MacRoman encoding has no interrobang character. When
                // building a name table, this case should be handled gracefully.
                const names = {
                    fontFamily: {
                        en: 'Hello‽'
                    }
                };
                const ltag = [];
                assert.deepEqual(getNameRecords(_name.make(names, ltag)), [
                    'Uni UTF-16 0 N1 [00 48 00 65 00 6C 00 6C 00 6F 20 3D]',
                    'Win UCS-2 English/US N1 [00 48 00 65 00 6C 00 6C 00 6F 20 3D]'
                ]);
                assert.deepEqual(ltag, ['en']);
            });
        
            it('can make a naming table for languages with unusual Mac script codes', function() {
                // Inuktitut ('iu') has a very unusual MacOS script code (smEthiopic)
                // although there are probably not too many Inuit in Ethiopia.
                // Apple had run out of script codes and needed a quick hack.
                // The implementation uses a secondary look-up table for handling such
                // corner cases (Inuktitut is not the only one), and this test exercises it.
                const names = {
                    fontFamily: {
                        iu: 'ᐊᐃᕕᖅ'
                    }
                };
                const ltag = [];
                assert.deepEqual(getNameRecords(_name.make(names, ltag)), [
                    'Mac smEthiopic langInuktitut N1 [84 80 CD E7]',
                    'Win UCS-2 Inuktitut/Canada N1 [14 0A 14 03 15 55 15 85]'
                ]);
                assert.deepEqual(ltag, []);
            });
        
            it('can make a naming table with custom names', function() {
                // Custom name for a font variation axis.
                const names = {
                    256: {
                        en: 'Width',
                        de: 'Breite'
                    }
                };
                const ltag = [];
                assert.deepEqual(getNameRecords(_name.make(names, ltag)), [
                    'Mac smRoman langEnglish N256 [57 69 64 74 68]',
                    'Mac smRoman langGerman N256 [42 72 65 69 74 65]',
                    'Win UCS-2 German/Germany N256 [00 42 00 72 00 65 00 69 00 74 00 65]',
                    'Win UCS-2 English/US N256 [00 57 00 69 00 64 00 74 00 68]'
                ]);
                assert.deepEqual(ltag, []);
            });
            */
        });
    }
}