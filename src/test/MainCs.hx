package;

import opentype.OpenType;
import opentype.Font;
import haxe.io.Bytes;

class MainCs {
    static public function main() {
        var fontBytes : Bytes;
        OpenType.loadFromFile("../../../fonts/lato.ttf", (b) -> {
            fontBytes = b;
            var font : Font;
            font = OpenType.parse(fontBytes);
            trace(font.unitsPerEm);
        }, (e) -> { trace(e); }
        );
    }
}