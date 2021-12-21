package opentype;

#if (sys || nodejs)
import sys.io.File;
import sys.FileSystem;
#end
import haxe.io.Bytes;
import opentype.tables.GlyphTable;
import opentype.tables.Cmap;
import opentype.tables.Gpos;
import opentype.tables.Head;
import opentype.tables.Hhea;
import opentype.tables.Kern;
import opentype.tables.Loca;
import opentype.tables.Ltag;
import opentype.tables.Name;
import opentype.tables.Maxp;
import opentype.tables.Hmtx;
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
        #if (js || !nodejs) 
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
        #else
        throw("Cannot load a font via the file system when runnning in the browser");
        #end
    }

    /**
    * Syncroniallsly loads a font from a file an return contant as Bytes.
    * @param  {string} path - The path of the file
    * @return {Bytes}        
    */
    public static function loadFromFileSync(path : String) : Bytes {
        #if (sys || nodejs)
        final bytes = File.getBytes(path);
        return bytes;
        #else
        throw("Cannot load a font via the file system when runnning in the browser");
        #end
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
    public static function uncompressTable(data : Bytes, tableEntry : TableEntry) : TableData {
	    if (tableEntry.compression == Woff) {
            var dest : haxe.io.Bytes = haxe.io.Bytes.alloc(tableEntry.length); 
        
        #if cs
            var inBuffer = new haxe.io.BytesInput(data, tableEntry.offset + 2);
            var ifl = new haxe.zip.InflateImpl(inBuffer, false);
            ifl.readBytes(dest,0, tableEntry.length);
	        return {data: dest, offset: 0};
        #elseif !nodejs
            var inBuffer = new haxe.io.BytesInput(data, tableEntry.offset + 2, tableEntry.compressedLength - 2);
            var uc = new haxe.zip.Uncompress();
            var res = uc.execute(data, tableEntry.offset + 2, dest, 0);
        #else
            var src = js.node.Buffer.hxFromBytes(data).slice(tableEntry.offset + 2);
            var dst = js.node.Buffer.hxFromBytes(dest);
            var res : js.node.Buffer = cast js.node.Zlib.inflateRawSync(src, cast {info: true, /* windowBits: windowBits */}).buffer;
            dst.set(res, 0);
        #end
	        return {data: dest, offset: 0};
	    } else {
	        return {data: data, offset: tableEntry.offset};
	    }
	}


    public static function parse(data : Bytes) : Font {
        var indexToLocFormat : Int = -1;
        var ltagTable = [];
    
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
	    var glyfTableEntry : TableEntry = null;
	    var gdefTableEntry;
	    var gposTableEntry : TableEntry = null;
	    var gsubTableEntry;
	    var hmtxTableEntry : TableEntry = null;
	    var kernTableEntry : TableEntry = null;
	    var locaTableEntry : TableEntry = null;
	    var nameTableEntry : TableEntry = null;
	    var metaTableEntry;
	    var p;

	    for (i in 0...numTables) {
	        var tableEntry = tableEntries[i];
	        var table : TableData;
	        switch (tableEntry.tag) {
	            case 'cmap':
	                table = uncompressTable(data, tableEntry);
	                font.tables.cmap = Cmap.parse(table.data, table.offset);
	                font.encoding = new opentype.Encoding.CmapEncoding(font.tables.cmap);
/*                    
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
*/                    
	            case 'head':
	                table = uncompressTable(data, tableEntry);
	                font.tables.head = Head.parse(table.data, table.offset);
	                font.unitsPerEm = font.tables.head.unitsPerEm;
	                indexToLocFormat = font.tables.head.indexToLocFormat;
                case 'hhea':
	                table = uncompressTable(data, tableEntry);
	                font.tables.hhea = Hhea.parse(table.data, table.offset);
	                //font.ascender = font.tables.hhea.ascender;
	                //font.descender = font.tables.hhea.descender;
	                font.numberOfHMetrics = font.tables.hhea.numberOfHMetrics;
	            case 'hmtx':
	                hmtxTableEntry = tableEntry;
                case 'ltag':
	                table = uncompressTable(data, tableEntry);
	                ltagTable = Ltag.parse(table.data, table.offset);
	            case 'maxp':
	                table = uncompressTable(data, tableEntry);
	                font.tables.maxp = Maxp.parse(table.data, table.offset);
	                font.numGlyphs = font.tables.maxp.numGlyphs;
                case 'name':
	                nameTableEntry = tableEntry;
	            /*
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
                */
	            case 'glyf':
	                glyfTableEntry = tableEntry;
	            case 'loca':
	                locaTableEntry = tableEntry;
                /*
	            case 'CFF ':
	                cffTableEntry = tableEntry;
	                break;
*/                    
	            case 'kern':
	                kernTableEntry = tableEntry;
/*	            case 'GDEF':
	                gdefTableEntry = tableEntry;
	                break;
*/                    
	            case 'GPOS': {
                    gposTableEntry = tableEntry;
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

        final nameTable = uncompressTable(data, nameTableEntry);
        //font.tables.name = Name.parse(nameTable.data, nameTable.offset, ltagTable);
        font.names = Name.parse(nameTable.data, nameTable.offset, ltagTable).properties;
        //font.names = font.tables.name;
        if (glyfTableEntry != null && locaTableEntry != null) {
            final shortVersion = indexToLocFormat == 0;
            final locaTable = uncompressTable(data, locaTableEntry);
            final loca = Loca.parse(locaTable.data, locaTable.offset, font.numGlyphs, shortVersion);
            final glyfTable = uncompressTable(data, glyfTableEntry);
            //font.glyphs = glyf.parse(glyfTable.data, glyfTable.offset, loca.glyphOffsets, font, opt);
            font.glyphs = GlyphTable.parse(glyfTable.data, glyfTable.offset, loca.glyphOffsets, font, false);
        } /* else if (cffTableEntry) {
            const cffTable = uncompressTable(data, cffTableEntry);
            cff.parse(cffTable.data, cffTable.offset, font, opt);
        } else {
            throw new Error('Font doesn\'t contain TrueType or CFF outlines.');
        }
    */
        final hmtxTable = uncompressTable(data, hmtxTableEntry);
        Hmtx.parse(hmtxTable.data, hmtxTable.offset, font, false);
        Encoding.addGlyphNames(font, false);

        if (kernTableEntry != null) {
            final kernTable = uncompressTable(data, kernTableEntry);
            font.kerningPairs = Kern.parse(kernTable.data, kernTable.offset).pairs;
        } else {
            font.kerningPairs = [];
        }

        if(gposTableEntry != null) {
            final gposTable = uncompressTable(data, gposTableEntry);
            font.tables.gpos = Gpos.parse(gposTable.data, gposTable.offset);
            font.position.init();
        }


        return font;
    }
}