package opentype;

import sys.io.File;
import sys.FileSystem;
import haxe.io.Bytes;
import opentype.tables.Gpos;
using opentype.BytesHelper;

class OpenType {
    // File loaders /////////////////////////////////////////////////////////
    /**
    * Loads a font from a file. The callback throws an error message as the first parameter if it fails
    * and the font as an ArrayBuffer in the second parameter if it succeeds.
    * @param  {string} path - The path of the file
    * @param  {Function} callback - The function to call when the font load completes
    */
    public static function loadFromFile(path : String, loaded : Bytes -> Void, error : Dynamic -> Void) {
        if(FileSystem.exists(path)) {
            try {
                final bytes = loadFromFileSync(path);
                loaded(bytes);
            } catch(e : Dynamic) {
                error(e);
            }
        } else {
            error('Loading font failed!. $path was not found!');
        }
    }

    /**
    * Syncroniallsly loads a font from a file an return contant as Bytes.
    * @param  {string} path - The path of the file
    * @return {Bytes}        
    */
    public static function loadFromFileSync(path : String) : Bytes {
        final bytes = File.getBytes(path);
        return bytes;
    }


/**
 * Loads a font from a URL. The callback throws an error message as the first parameter if it fails
 * and the font as an ArrayBuffer in the second parameter if it succeeds.
 * @param  {string} url - The URL of the font file.
 * @param  {Function} callback - The function to call when the font load completes
 */
/*
 function loadFromUrl(url, callback) {
    const request = new XMLHttpRequest();
    request.open('get', url, true);
    request.responseType = 'arraybuffer';
    request.onload = function() {
        if (request.response) {
            return callback(null, request.response);
        } else {
            return callback('Font could not be loaded: ' + request.statusText);
        }
    };

    request.onerror = function () {
        callback('Font could not be loaded');
    };

    request.send();
}
    */

    // Table Directory Entries //////////////////////////////////////////////
    /**
    * Parses OpenType table entries.
    * @param  {DataView}
    * @param  {Number}
    * @return {Object[]}
    */
    public static function parseOpenTypeTableEntries(data : Bytes, numTables : Int) : Array<TableEntry> {
        final tableEntries : Array<TableEntry> = [];
        var p = 12;
        for (i in 0...numTables) {
            final tag = Parser.getTag(data, p);
            final checksum = data.readULong(p + 4);
            final offset = data.readULong(p + 8);
            final length = data.readULong(p + 12);
            tableEntries.push({tag: tag, checksum: checksum, offset: offset, length: length, compression: None});
            p += 16;
        }
        return tableEntries;
    }

    /**
    * Parses WOFF table entries.
    * @param  {DataView}
    * @param  {Number}
    * @return {Object[]}
    */
    public static function parseWOFFTableEntries(data : Bytes, numTables : Int) {
        final tableEntries : Array<TableEntry> = [];
        var p = 44; // offset to the first table directory entry.
        for (i in 0...numTables) {
            final tag = Parser.getTag(data, p);
            final offset = data.readULong(p + 4);
            final compLength = data.readULong(p + 8);
            final origLength = data.readULong(p + 12);
            var compression : Compression;
            if (compLength < origLength) {
                compression = Woff;
            } else {
                compression = None;
            }

            tableEntries.push({tag: tag, checksum: -1, offset: offset, compression: compression, compressedLength: compLength, length: origLength});
            p += 20;
        }

        return tableEntries;
    }    

	/**
	 * @typedef TableData
	 * @type Object
	 * @property {DataView} data - The DataView
	 * @property {number} offset - The data offset.
	 */

	/**
	 * @param  {DataView}
	 * @param  {Object}
	 * @return {TableData}
	 */
    public static function uncompressTable(data : Bytes, tableEntry : TableEntry) : Table {
	    if (tableEntry.compression == Woff) {
            var dest : haxe.io.Bytes = haxe.io.Bytes.alloc(tableEntry.length); 
        #if !nodejs
            var inBuffer = new haxe.io.BytesInput(data, tableEntry.offset + 2, tableEntry.compressedLength - 2);
            var uc = new haxe.zip.Uncompress();
            var res = uc.execute(data, tableEntry.offset + 2, dest, 0);
        #else
            var src = js.node.Buffer.hxFromBytes(data).slice(tableEntry.offset + 2);
            var dst = js.node.Buffer.hxFromBytes(dest);
            var res = cast js.node.Zlib.inflateRawSync(src, cast {info: true, /* windowBits: windowBits */});
            var engine = res.engine;
            var res : js.node.Buffer = res.buffer;
            dst.set(res, 0);
        #end


	        return {data: dest, offset: 0};
	    } else {
	        return {data: data, offset: tableEntry.offset};
	    }
	}


    public static function parse(data : Bytes) : Font {
        var indexToLocFormat;
        var ltagTable;
    
        final font = new Font();
    
        // OpenType fonts use big endian byte ordering.
        var bi = new haxe.io.BytesInput(data);
        bi.bigEndian = true;
        data = bi.readAll();


        var numTables;
        var tableEntries = [];
        final signature : String = Parser.getTag(data, 0);

        if (signature == BytesHelper.fromCharCodes([0, 1, 0, 0]) || signature == 'true' || signature == 'typ1') {
            font.outlinesFormat = Ttf;
            numTables = data.readU16BE(4);
            tableEntries = parseOpenTypeTableEntries(data, numTables);
        } else if (signature == 'wOFF') {   
            final flavor = Parser.getTag(data, 4);
            if (flavor == BytesHelper.fromCharCodes([0, 1, 0, 0])) {
                font.outlinesFormat = Ttf;
            } else {
                throw('Unsupported OpenType flavor ' + signature);
            }
    
            numTables = data.readU16BE(12);
            tableEntries = parseWOFFTableEntries(data, numTables);
        } else {
            throw('Unsupported OpenType signature ' + signature);
        }
    
	    var cffTableEntry;
	    var fvarTableEntry;
	    var glyfTableEntry;
	    var gdefTableEntry;
	    var gposTableEntry;
	    var gsubTableEntry;
	    var hmtxTableEntry;
	    var kernTableEntry;
	    var locaTableEntry;
	    var nameTableEntry;
	    var metaTableEntry;
	    var p;

	    for (i in 0...numTables) {
	        var tableEntry = tableEntries[i];
	        var table : Table;
	        switch (tableEntry.tag) {
/*                    
	            case 'cmap':
	                table = uncompressTable(data, tableEntry);
	                font.tables.cmap = cmap.parse(table.data, table.offset);
	                font.encoding = new CmapEncoding(font.tables.cmap);
	                break;
	            case 'cvt ' :
	                table = uncompressTable(data, tableEntry);
	                p = new parse.Parser(table.data, table.offset);
	                font.tables.cvt = p.parseShortList(tableEntry.length / 2);
	                break;
	            case 'fvar':
	                fvarTableEntry = tableEntry;
	                break;
	            case 'fpgm' :
	                table = uncompressTable(data, tableEntry);
	                p = new parse.Parser(table.data, table.offset);
	                font.tables.fpgm = p.parseByteList(tableEntry.length);
	                break;
	            case 'head':
	                table = uncompressTable(data, tableEntry);
	                font.tables.head = head.parse(table.data, table.offset);
	                font.unitsPerEm = font.tables.head.unitsPerEm;
	                indexToLocFormat = font.tables.head.indexToLocFormat;
	                break;
	            case 'hhea':
	                table = uncompressTable(data, tableEntry);
	                font.tables.hhea = hhea.parse(table.data, table.offset);
	                font.ascender = font.tables.hhea.ascender;
	                font.descender = font.tables.hhea.descender;
	                font.numberOfHMetrics = font.tables.hhea.numberOfHMetrics;
	                break;
	            case 'hmtx':
	                hmtxTableEntry = tableEntry;
	                break;
	            case 'ltag':
	                table = uncompressTable(data, tableEntry);
	                ltagTable = ltag.parse(table.data, table.offset);
	                break;
	            case 'maxp':
	                table = uncompressTable(data, tableEntry);
	                font.tables.maxp = maxp.parse(table.data, table.offset);
	                font.numGlyphs = font.tables.maxp.numGlyphs;
	                break;
	            case 'name':
	                nameTableEntry = tableEntry;
	                break;
	            case 'OS/2':
	                table = uncompressTable(data, tableEntry);
	                font.tables.os2 = os2.parse(table.data, table.offset);
	                break;
	            case 'post':
	                table = uncompressTable(data, tableEntry);
	                font.tables.post = post.parse(table.data, table.offset);
	                font.glyphNames = new GlyphNames(font.tables.post);
	                break;
	            case 'prep' :
	                table = uncompressTable(data, tableEntry);
	                p = new parse.Parser(table.data, table.offset);
	                font.tables.prep = p.parseByteList(tableEntry.length);
	                break;
	            case 'glyf':
	                glyfTableEntry = tableEntry;
	                break;
	            case 'loca':
	                locaTableEntry = tableEntry;
	                break;
	            case 'CFF ':
	                cffTableEntry = tableEntry;
	                break;
	            case 'kern':
	                kernTableEntry = tableEntry;
	                break;
	            case 'GDEF':
	                gdefTableEntry = tableEntry;
	                break;
*/                    
	            case 'GPOS': {
                    final gposTable = uncompressTable(data, tableEntry);
                    font.tables.gpos = Gpos.parse(gposTable.data, gposTable.offset);
                    
                    //font.position.init();
                }
/*
                case 'GSUB':
	                gsubTableEntry = tableEntry;
	                break;
	            case 'meta':
	                metaTableEntry = tableEntry;
	                break;
                    */
	        }
	    }

        return font;
    }
}