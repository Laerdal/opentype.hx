package opentype;

class Glyph {
    public function new(options : GlyphOptions) {
        this.index = options.index > 0 ? options.index : 0;

        // These three values cannot be deferred for memory optimization:
        this.name = options.name;
        this.unicode = options.unicode > 0 ? options.unicode : 0;
        this.unicodes = options.unicodes != null ? options.unicodes : options.unicode > 0 ? [options.unicode] : [];
            
    }

    public var name : String;
    public var unicode : Int;
    public var unicodes : Array<Int>;
    
    
    public var index : Int;
    public var advanceWidth : Int;
    public var leftSideBearing : Int;
    public var path : Path;

    /**
    * @param {number}
    */
    public function addUnicode(unicode : Int) {
        if (unicodes.length == 0) {
            this.unicode = unicode;
        }

        unicodes.push(unicode);
    };    
}

@:structInit
class GlyphOptions {
    public function new(?name: String, ?index : Int, ?unicode: Int, ?advanceWidth : Int, ?path : Path) {
        this.name = name;
        this.index = index;
        this.unicode = unicode;
        this.advanceWidth = advanceWidth;
        this.path = path;
    }
    public var index : Int;
    public var name : String;
    public var unicode : Int;
    public var unicodes : Array<Int>;
    public var xMin : Int;
    public var yMin : Int;
    public var xMax : Int;
    public var yMax : Int;
    public var advanceWidth : Int;
    public var path : Path;
}