
using buddy.Should;
using TestUtil;
import opentype.Types;

class TestTypes extends buddy.BuddySuite {
    public function new() {
        describe('Types.hx', {
            it('can handle BYTE', {
                Types.encodeByte(0xFE).hex().should.be('FE');
                Types.sizeOfByte().should.be(1);
            });
            
            it('can handle CHAR', {
                Types.encodeChar('@').hex().should.be('40');
                Types.sizeOfChar().should.be(1);
            });

            it('can handle CHARARRAY', {
                Types.encodeCharArray('A/B').hex().should.be('41 2F 42');
                Types.sizeOfCharArray('A/B').should.be(3);
            });

            it('can handle null as CHARARRAY', {
                Types.encodeCharArray(null).hex().should.be('');
                Types.sizeOfCharArray(null).should.be(0);
            });

            it('can handle USHORT', {
                Types.encodeUShort(0xCAFE).hex().should.be('CA FE');
                Types.sizeOfUShort().should.be(2);
            });
        
            it('can handle SHORT', {
               Types.encodeShort(-345).hex().should.be('FE A7');
               Types.sizeOfShort().should.be(2);
            });            

            it('can handle UINT24', {
                Types.encodeUInt24(0xABCDEF).hex().should.be('AB CD EF');
                Types.sizeOfUInt24().should.be(3);
            });

            it('can handle ULONG', function() {
                Types.encodeULong(0xDEADBEEF).hex().should.be('DE AD BE EF');
                Types.sizeOfULong().should.be(4);
            });
        
            it('can handle LONG', function() {
                Types.encodeLong(-123456789).hex().should.be('F8 A4 32 EB');
                Types.sizeOfLong().should.be(4);
            });

            it('can handle FIXED', function() {
                Types.encodeFixed(0xBEEFCAFE).hex().should.be('BE EF CA FE');
                Types.sizeOfFixed().should.be(4);
            });        

            it('can handle FWORD', function() {
                Types.encodeFWord(-8193).hex().should.be('DF FF');
                Types.sizeOfFWord().should.be(2);
            });
        
            it('can handle UFWORD', function() {
                Types.encodeUFWord(0xDEED).hex().should.be('DE ED');
                Types.sizeOfUFWord().should.be(2);
            });
        
            it('can handle LONGDATETIME', function() {
                Types.encodeLongDatetime(0x3F7A43B1).hex().should.be('00 00 00 00 3F 7A 43 B1');
                Types.sizeOfUFWord().should.be(2);
            });

            
            it('can handle TAG', {
                Types.encodeTag('Font').hex().should.be('46 6F 6E 74');
                Types.sizeOfTag().should.be(4);
            });

            it('can handle Card8', function() {
                Types.encodeCard8(0xFE).hex().should.be('FE');
                Types.sizeOfCard8().should.be(1);
            });
        
            it('can handle Card16', function() {
                Types.encodeCard16(0xCAFE).hex().should.be('CA FE');
                Types.sizeOfCard16().should.be(2);
            });
        
            it('can handle OffSize', function() {
                Types.encodeOffSize(0xFE).hex().should.be('FE');
                Types.sizeOfOffSize().should.be(1);
            });
        
            it('can handle SID', function() {
                Types.encodeSID(0xCAFE).hex().should.be('CA FE');
                Types.sizeOfSID().should.be(2);
            });
        
            it('can handle NUMBER', function() {
                Types.encodeNumber(-32769).hex().should.be('1D FF FF 7F FF');
                Types.encodeNumber(-32768).hex().should.be('1C 80 00');
                Types.encodeNumber(-32767).hex().should.be('1C 80 01');
                Types.encodeNumber(-1133).hex().should.be('1C FB 93');
                Types.encodeNumber(-1132).hex().should.be('1C FB 94');
                Types.encodeNumber(-1131).hex().should.be('FE FF');
                Types.encodeNumber(-109).hex().should.be('FB 01');
                Types.encodeNumber(-108).hex().should.be('FB 00');
                Types.encodeNumber(-107).hex().should.be('20');
                Types.encodeNumber(-106).hex().should.be('21');
                Types.encodeNumber(0).hex().should.be('8B');
                Types.encodeNumber(107).hex().should.be('F6');
                Types.encodeNumber(108).hex().should.be('F7 00');
                Types.encodeNumber(109).hex().should.be('F7 01');
                Types.encodeNumber(1131).hex().should.be('FA FF');
                Types.encodeNumber(1132).hex().should.be('1C 04 6C');
                Types.encodeNumber(1133).hex().should.be('1C 04 6D');
                Types.encodeNumber(32767).hex().should.be('1C 7F FF');
                Types.encodeNumber(32768).hex().should.be('1D 00 00 80 00');
                Types.encodeNumber(32769).hex().should.be('1D 00 00 80 01');
        
                Types.sizeOfNumber(-32769).should.be(5);
                Types.sizeOfNumber(-32768).should.be(3);
                Types.sizeOfNumber(-32767).should.be(3);
                Types.sizeOfNumber(-1133).should.be(3);
                Types.sizeOfNumber(-1132).should.be(3);
                Types.sizeOfNumber(-1131).should.be(2);
                Types.sizeOfNumber(-109).should.be(2);
                Types.sizeOfNumber(-108).should.be(2);
                Types.sizeOfNumber(-107).should.be(1);
                Types.sizeOfNumber(-106).should.be(1);
                Types.sizeOfNumber(0).should.be(1);
                Types.sizeOfNumber(107).should.be(1);
                Types.sizeOfNumber(108).should.be(2);
                Types.sizeOfNumber(109).should.be(2);
                Types.sizeOfNumber(1131).should.be(2);
                Types.sizeOfNumber(1132).should.be(3);
                Types.sizeOfNumber(1133).should.be(3);
                Types.sizeOfNumber(32767).should.be(3);
                Types.sizeOfNumber(32768).should.be(5);
                Types.sizeOfNumber(32769).should.be(5);
            });
            
            it('can handle NUMBER16', function() {
                Types.encodeNumber16(-32768).hex().should.be('1C 80 00');
                Types.encodeNumber16(-1133).hex().should.be('1C FB 93');
                Types.encodeNumber16(-108).hex().should.be('1C FF 94');
                Types.encodeNumber16(0).hex().should.be('1C 00 00');
                Types.encodeNumber16(108).hex().should.be('1C 00 6C');
                Types.encodeNumber16(1133).hex().should.be('1C 04 6D');
                Types.encodeNumber16(32767).hex().should.be('1C 7F FF');
        
                Types.sizeOfNumber16().should.be(3);
                //Why did the OpenType.js implementation provided an argument for the sizeOfSomeNumber functions when that argument wasn't used for anything?
                //Types.sizeOfNumber16(-1133).should.be(3);
                //Types.sizeOfNumber16(-108).should.be(3);
                //Types.sizeOfNumber16(0).should.be(3);
                //Types.sizeOfNumber16(108).should.be(3);
                //Types.sizeOfNumber16(1133).should.be(3);
                //Types.sizeOfNumber16(32767).should.be(3);
            });

            it('can handle UTF16', function() {
                Types.decodeUtf16('DE AD 5B 57 4F 53'.unhex(), 2, 4).should.be('字体');
                Types.encodeUtf16('字体').hex().should.be('5B 57 4F 53');
                Types.sizeOfUtf16('字体').should.be(4);
        
                // In JavaScript, characters outside the Basic Multilingual Plane
                // are represented with surrogate pairs. For example, U+1F404 COW
                // is stored as the surrogate pair U+D83D U+DC04. This is also
                // exactly what we need for representing U+1F404 in UTF-16.
                Types.decodeUtf16('DE AD D8 3D DC 04'.unhex(), 2, 4).should.be('🐄');
                Types.encodeUtf16('🐄').hex().should.be('D8 3D DC 04');
                Types.sizeOfUtf16('🐄').should.be(4);
            });            

            it('can handle TABLE', {
                final table = new opentype.Table("", [
                    {name: 'version', type: 'FIXED', value: 0x01234567},
                    {name: 'flags', type: 'USHORT', value: 0xBEEF}
                ]);
                Types.encodeTable(table).hex().should.be('01 23 45 67 BE EF');
                Types.sizeOfTable(table).should.be(6);
            });

            it('can handle subTABLEs', function() {
                final table = new opentype.Table("", [
                        {name: 'version', type: 'FIXED', value: 0x01234567},
                        {
                            name: 'subtable', type: 'TABLE', value: new opentype.Table("", [
                                    {name: 'flags', type: 'USHORT', value: 0xBEEF}
                                ]
                            )
                        }
                    ]
                );
                Types.encodeTable(table).hex().should.be('01 23 45 67 00 06 BE EF');
                Types.sizeOfTable(table).should.be(8);
            });            

        });
    }
}