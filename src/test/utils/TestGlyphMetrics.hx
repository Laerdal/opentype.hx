package utils;

using buddy.Should;
import haxe.io.Bytes;
import opentype.OpenType;
import opentype.Font;
import opentype.utils.GlyphMetrics;

class TestGlyphMetrics extends buddy.BuddySuite {
    public function new() {
        describe('GlyphMetrics', {
            var fontBytes : Bytes;
            var font : Font;
            OpenType.loadFromFile("fonts/lato.ttf", (b) -> {
                    fontBytes = b;
                    font = OpenType.parse(fontBytes);
                }, (e) -> { trace(e); }
            );        
        
            describe('hMetrics', function() {
                it("can get advanceWidth for a character code", {
                    var gm : GlyphMetrics = new GlyphMetrics(font);
                    gm.hMetrics.getAdvanceWidth(0x0).should.be(0);//.NotDef
                    gm.hMetrics.getAdvanceWidth(' '.code).should.be(386);
                    gm.hMetrics.getAdvanceWidth('B'.code).should.be(1294);
                    gm.hMetrics.getAdvanceWidth('~'.code).should.be(1160);
                });
                it("can get advanceWidth for a character code", {
                    var gm : GlyphMetrics = new GlyphMetrics(font);
                    gm.hMetrics.getKerningForPair('A'.code, 'Y'.code).should.be(-164);
                });
            });
        });
    }
}