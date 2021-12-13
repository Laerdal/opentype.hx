package opentype;

class Glyph {
    public function new(options : GlyphOptions) {
        
    }

    public var advanceWidth : Int;
    public var leftSideBearing : Int;
}

@:structInit
class GlyphOptions {
    public function new(name: String, unicode: Int ) {
        this.name = name;
        this.unicode = unicode;
    }
    public var name : String;
    public var unicode : Int;
    public var unicodes : Array<Int>;
    public var xMin : Int;
    public var yMin : Int;
    public var xMax : Int;
    public var yMax : Int;
    public var advanceWidth : Int;     
}