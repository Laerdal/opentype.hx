package opentype.tables;

import haxe.io.Bytes;

class Kern {
    public var pairs : Map<String, Int>;
    public function new() {
        pairs = [];
    }
    public static function parse(data : Bytes, position : Int) : Kern {
        final kern = new Kern();
        final p = new Parser(data, position);

        final tableVersion = p.parseUShort();
        if (tableVersion == 0) {
            kern.pairs = parseWindowsKernTable(p);
        } else if (tableVersion == 1) {
            kern.pairs = parseMacKernTable(p);
        } else {
            throw('Unsupported kern table version ("$tableVersion"');
        }
        return kern; 
    }

    static function parseWindowsKernTable(p : Parser) : Map<String,Int> {
        final pairs = new Map();
        // Skip nTables.
        p.skipUShort();
        final subtableVersion = p.parseUShort();
        Check.assert(subtableVersion == 0, 'Unsupported kern sub-table version. "$subtableVersion"');
        // Skip subtableLength, subtableCoverage
        p.skipUShort(2);
        final nPairs = p.parseUShort();
        // Skip searchRange, entrySelector, rangeShift.
        p.skipUShort(3);
        for (i in 0...nPairs) {
            final leftIndex = p.parseUShort();
            final rightIndex = p.parseUShort();
            final value = p.parseShort();
            pairs[leftIndex + ',' + rightIndex] = value;
        }
        return pairs;
    }
    
    static function parseMacKernTable(p : Parser) : Map<String,Int> {
        // The Mac kern table stores the version as a fixed (32 bits) but we only loaded the first 16 bits.
        final pairs = new Map();
        // Skip the rest.
        p.skipUShort();
        final nTables = p.parseULong();
        //check.argument(nTables === 1, 'Only 1 subtable is supported (got ' + nTables + ').');
        if (nTables > 1) {
            //.warn('Only the first kern subtable is supported.');
        }
        p.skipULong();
        final coverage = p.parseUShort();
        final subtableVersion = coverage & 0xFF;
        p.skipUShort();
        if (subtableVersion == 0) {
            final nPairs = p.parseUShort();
            // Skip searchRange, entrySelector, rangeShift.
            p.skipUShort(3);
            for (i in 0...nPairs) {
                final leftIndex = p.parseUShort();
                final rightIndex = p.parseUShort();
                final value = p.parseShort();
                pairs[leftIndex + ',' + rightIndex] = value;
            }
        }
        return pairs;
    }


}