
class TestOpenTypeJs {
    public static function main() {
        trace("Hello");
        var ot = js.Lib.require("./opentype.js");
        ot.load(
            "fonts/lato.ttf", 
            (e,f) -> { trace("Done"); }

        );
    }
}