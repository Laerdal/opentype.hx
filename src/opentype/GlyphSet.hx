package opentype;



class GlyphSet {
    public function new(font : Font) {
        
    }

    /**
    * @param  {number} index
    * @param  {Object}
    */
    public function push(index : Int, loader) {
        //this.glyphs[index] = loader;
        //this.length++;
    };
    
    public function get(index : Int) : Glyph {
        return new Glyph();
    }
}