package utils;

using buddy.Should;
import haxe.io.Bytes;
import opentype.OpenType;
import opentype.Font;
import opentype.utils.GlyphMetrics;

class TestGlyphMetrics extends buddy.BuddySuite {
    public function new() {
        describe('GlyphMetrics', {
            describe('Using Lato font then hMetrics', function() {
                var fontBytes : Bytes;
                var font : Font;
                OpenType.loadFromFile("fonts/lato.ttf", (b) -> {
                        fontBytes = b;
                        font = OpenType.parse(fontBytes);
                    }, (e) -> { trace(e); }
                );                        
                it("can get advanceWidth for a character code", {
                    var gm : GlyphMetrics = new GlyphMetrics(font);
                    gm.hMetrics.getGlyphMetricsForChar(0x0).advanceWidth.should.be(0);//.NotDef
                    gm.hMetrics.getGlyphMetricsForChar(' '.code).advanceWidth.should.be(386);
                    gm.hMetrics.getGlyphMetricsForChar('B'.code).advanceWidth.should.be(1294);
                    gm.hMetrics.getGlyphMetricsForChar('~'.code).advanceWidth.should.be(1160);
                });
                it("can get kernings for a character pair", {
                    var gm : GlyphMetrics = new GlyphMetrics(font);
                    gm.hMetrics.getGlyphMetricsForChar('A'.code).kerningPairs['Y'.code].should.be(-164);
                    gm.hMetrics.getGlyphMetricsForChar('L'.code).kerningPairs['™'.code].should.be(-290);
                });
            });
            describe('Using Arial font then hMetrics', function() {
                var fontBytes : Bytes;
                var font : Font;
                OpenType.loadFromFile("fonts/arial.ttf", (b) -> {
                        fontBytes = b;
                        font = OpenType.parse(fontBytes);
                    }, (e) -> { trace(e); }
                );                        
                it("can get advanceWidth for a character code", {
                    var gm : GlyphMetrics = new GlyphMetrics(font);
                    gm.hMetrics.getGlyphMetricsForChar(' '.code).advanceWidth.should.be(569);
                    gm.hMetrics.getGlyphMetricsForChar('P'.code).advanceWidth.should.be(1366);
                    gm.hMetrics.getGlyphMetricsForChar('^'.code).advanceWidth.should.be(961);
                });
                it("can get kernings for a character pair", {
                    var gm : GlyphMetrics = new GlyphMetrics(font);
                    gm.hMetrics.getGlyphMetricsForChar('T'.code).kerningPairs['A'.code].should.be(-152);
                });
            });
        });
    }
}