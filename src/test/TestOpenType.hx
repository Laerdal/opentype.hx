
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
            describe('font', {
                var fontBytes : Bytes;
                var font : Font;
                beforeAll(function(done) {
                    OpenType.loadFromFile("fonts/lato.ttf", (b) -> {
                        fontBytes = b;
                        font = OpenType.parse(fontBytes);
                        done();
                    }, (e) -> {});
                });
                it("hasChar can check if font has a glyph for a given character.", {
                    font.hasChar(0).should.be(true); //Null default character
                    font.hasChar(0x000D).should.be(true);//Nonmarkingreturn
                    font.hasChar(0x000C).should.be(false);//Control character not expected to be included in lato
                    font.hasChar(' '.code).should.be(true); //Space character - 32(0x20)
                    font.hasChar('A'.code).should.be(true);
                });

                it("charToGlyphIndex can find a index for a given charater.", {
                    font.charToGlyphIndex(0).should.be(1); //Null default character should be the first
                    font.charToGlyphIndex(0x000D).should.be(2); //Nonmarkingreturn should be second
                    font.charToGlyphIndex(' '.code).should.be(3); //Space character - 32(0x20)
                    font.charToGlyphIndex('A'.code).should.be(36);//A 36
                });       
                
                it("charToGlyph can find a glyph for a given charater.", {
                    font.charToGlyph('A'.code).unicode.should.be(65); //Null default character should be the first
                    font.charToGlyph(' '.code).unicode.should.be(32); //Null default character should be the first
                });
                

                it("charToGlyphIndex can find a index for a given charater.", {
                    var ia = font.charToGlyphIndex('A'.code);
                    var iw = font.charToGlyphIndex('W'.code);
                    font.getKerningValueForIndexes(ia, iw).should.be(-84);
                });
                


            });
        });
    }
}