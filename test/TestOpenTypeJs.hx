
class TestOpenTypeJs {
    public static function main() {
        trace("Hello");
        var ot = js.Lib.require("./opentype.js");
        ot.load(
            "fonts/arial.ttf", 
            (e,f) -> { trace("Done"); }

        );
    }
}