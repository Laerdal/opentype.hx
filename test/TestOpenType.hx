
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
                    OpenType.loadFromFile("fonts/lato.ttf", (b) -> {
                        fontBytes = b;
                        done();
                    }, (e) -> {});
                });
                var font : Font;
                it("can parse Bytes to Font type.", {
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
                it("can parse Bytes to Font type.", {
                    font = OpenType.parse(fontBytes);
                    font.should.beType(Font);
                });
                it("can detect and set outlinesFormat.", {
                    font.outlinesFormat.should.equal(opentype.Flavor.Ttf);
                });
            });

            
        });
    }
}