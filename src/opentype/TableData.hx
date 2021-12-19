package opentype;

import haxe.io.Bytes;

@:structInit
class TableData {
    public function new(
        data : Bytes,
        offset : Int
    ) {
        this.data = data;
        this.offset = offset;
    }

    public var data: Bytes;
    public var offset: Int;
}