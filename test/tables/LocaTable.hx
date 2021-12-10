package tables;

using buddy.Should;
import opentype.tables.Loca; 
using TestUtil;

class LocaTable extends buddy.BuddySuite {
    public function new() {
        describe('tables/Loca.hx', {
            it('can parse the short version', function() {
                final data = 'DEAD BEEF 0010 0100 80CE'.unhex();
                final loca : Loca = Loca.parse(data, 4, 2, true);
                loca.glyphOffsets.should.containExactly([32, 512, 2 * 0x80ce]);
            });
        
            it('can parse the long version', function() {
                final data = 'DEADBEEF 00000010 00000100 ABCD5678'.unhex();
                final loca : Loca = Loca.parse(data, 4, 2, false);
                loca.glyphOffsets.should.containExactly([0x10, 0x100, 0xabcd5678]);
            });
        });
    }
}
