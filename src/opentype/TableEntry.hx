package opentype;

@:structInit
class TableEntry {
    public function new(
        tag: String, 
        checksum: Int, 
        offset: Int, 
        length: Int, 
        compression: Compression,
        ?compressedLength: Int
    ) {
        this.tag = tag; 
        this.checksum = checksum;  
        this.offset = offset;
        this.length = length;
        this.compression = compression;
        this.compressedLength = compressedLength;
    }
    public var tag : String; 
    public var checksum : Int;  
    public var offset : Int;
    public var length : Int;
    public var compression : Compression;
    public var compressedLength : Int;
}