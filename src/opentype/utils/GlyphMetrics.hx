package opentype.utils;

import opentype.utils.HorizontalGlyphMetrics;

class GlyphMetrics {
    public function new(font : Font) {
        this.hMetrics = new HorizontalGlyphMetrics(font);
    }

    public var hMetrics(default, null) : HorizontalGlyphMetrics;
}