
using buddy.Should;
import opentype.OpenType;
import opentype.Font;
import haxe.io.Bytes;

class TestOpenType extends buddy.BuddySuite {
    public function new() {
        describe("Test that OpenType", {
            describe('loadFont', {
                var fontBytes : Bytes;
                var error : Dynamic;
                // Add function(done) here to enable async testing:
                beforeAll(function(done) {
                    OpenType.loadFromFile("fonts/lato.ttf", (b) -> {
                        fontBytes = b;
                        done();
                    }, (e) -> {
                        error = e;
                        done();
                    });
                });
                it("can load a ttf font as Bytes.", {
                    fontBytes.should.beType(Bytes);
                    error.should.be(null);
                });
            });
            describe('parse', {
                var fontBytes : Bytes;
                beforeAll(function(done) {
                    OpenType.loadFromFile("fonts/arial.ttf", (b) -> {
                        fontBytes = b;
                        done();
                    }, (e) -> {});
                });
                var font : Font;
                it("can parse Bytes of ttf to Font type.", {
                    font = OpenType.parse(fontBytes);
                    font.should.beType(Font);
                });
                it("can detect and set outlinesFormat.", {
                    font.outlinesFormat.should.equal(opentype.Flavor.Ttf);
                });
            });
            describe('parse', {
                var fontBytes : Bytes;
                beforeAll(function(done) {
                    OpenType.loadFromFile("fonts/lato.woff", (b) -> {
                        fontBytes = b;
                        done();
                    }, (e) -> {});
                });
                var font : Font;
                it("can parse Bytes of woff to Font type.", {
                    font = OpenType.parse(fontBytes);
                    font.should.beType(Font);
                });
                it("can detect and set outlinesFormat.", {
                    font.outlinesFormat.should.equal(opentype.Flavor.Ttf);
                });
            });
            describe('Using fonts/lato.ttf test that', {
                var fontBytes : Bytes;
                var font : Font;
                beforeAll(function(done) {
                    OpenType.loadFromFile("fonts/lato.ttf", (b) -> {
                        fontBytes = b;
                        font = OpenType.parse(fontBytes);
                        done();
                    }, (e) -> {});
                });
                describe('Font.names', {
                    it("contains font name info", {
                        font.names["fontFamily"]["en"].should.be("Lato");
                        font.names["fullName"]["en"].should.be("Lato Regular");
                        font.names["fontSubfamily"]["en"].should.be("Regular");
                    });
                });
                describe('Font.hasChar', {
                    it("can check if font has a glyph for a given character.", {
                        font.hasChar(0).should.be(true); //Null default character
                        font.hasChar(0x000D).should.be(true);//Nonmarkingreturn
                        font.hasChar(0x000C).should.be(false);//Control character not expected to be included in lato
                        font.hasChar(' '.code).should.be(true); //Space character - 32(0x20)
                        font.hasChar('A'.code).should.be(true);
                    });
                });
                describe('Font.charToGlyphIndex', {
                    it("can find a index for a given charater.", {
                        font.charToGlyphIndex(0).should.be(1); //Null default character should be the first
                        font.charToGlyphIndex(0x000D).should.be(2); //Nonmarkingreturn should be second
                        font.charToGlyphIndex(' '.code).should.be(3); //Space character - 32(0x20)
                        font.charToGlyphIndex('A'.code).should.be(36);//A 36
                    });
                });       
                describe('Font.charToGlyph', {
                    it("can find a glyph for a given charater.", {
                        font.charToGlyph('A'.code).unicode.should.be(0x0041);
                        font.charToGlyph('A'.code).advanceWidth.should.be(1360);
                        font.charToGlyph(' '.code).unicode.should.be(0x20);
                        font.charToGlyph(' '.code).advanceWidth.should.be(386);
                        font.charToGlyph('~'.code).unicode.should.be(0x007E);
                        font.charToGlyph('~'.code).advanceWidth.should.be(1160);
                    });
                });
                describe('Font.getKerningValueForIndexes', {
                    it("can find a kerning value for two following characters", {
                        final getKerningValue = (s : String) -> {
                            return font.getKerningValueForIndexes(
                                font.charToGlyphIndex(s.charCodeAt(0)),
                                font.charToGlyphIndex(s.charCodeAt(1))
                            );
                        }
                        getKerningValue('AW').should.be(-84);
                        getKerningValue('To').should.be(-210);
                        getKerningValue('Lf').should.be(0);
                    });   
                });
                describe('Font.getGlyphIndicies', {
                    it("can get all font indicies", {
                        var indicies = font.getGlyphIndicies();
                        trace(indicies.length);
                        var kerningPairs = [for(i in indicies) font.getKerningPairs(i) ];
                        trace(kerningPairs.length);
                        trace(font.getChars().length);
                        var indexSpace = font.charToGlyphIndex(32);
                        var space = font.charToGlyph(32);
                        trace(space.advanceWidth);
                    });
                });
            });
            describe('Using fonts/arial.ttf test that', {
                var fontBytes : Bytes;
                var font : Font;
                beforeAll(function(done) {
                    OpenType.loadFromFile("fonts/arial.ttf", (b) -> {
                        fontBytes = b;
                        font = OpenType.parse(fontBytes);
                        done();
                    }, (e) -> {});
                });
                describe('Font.hasChar', {
                    it("can check if font has a glyph for a given character.", {
                        font.hasChar(0).should.be(false); //Null default character
                        font.hasChar(' '.code).should.be(true); //Space character - 32(0x20)
                        font.hasChar('A'.code).should.be(true);
                        font.hasChar(0x000C).should.be(false);//Control character not expected to be included in arial
                        font.hasChar(0x00A0).should.be(true);//NO-BREAK_SPACE
                    });
                });
                describe('Font.hasChar', {
                        it("charToGlyphIndex can find a index for a given charater.", {
                        font.charToGlyphIndex(0).should.be(0); //Null default character should be the first
                        font.charToGlyphIndex(' '.code).should.be(3); //Space character - 32(0x20)
                        font.charToGlyphIndex('A'.code).should.be(36);//A 36
                    });
                });
                describe('Font.charToGlyph', {
                    it("can find a glyph for a given charater.", {
                        font.charToGlyph('A'.code).unicode.should.be(65); //Null default character should be the first
                        font.charToGlyph(' '.code).unicode.should.be(32); //Null default character should be the first
                    });
                });
                describe('Font.getKerningValueForIndexes', {
                        it("can find a kerning value for two following characters", {
                        final getKerningValue = (s : String) -> {
                            return font.getKerningValueForIndexes(
                                font.charToGlyphIndex(s.charCodeAt(0)),
                                font.charToGlyphIndex(s.charCodeAt(1))
                            );
                        }
                        getKerningValue('AW').should.be(-76);
                        getKerningValue('To').should.be(-227);
                        getKerningValue('Lf').should.be(0);
                    });
                });
            });
        });
    }
}