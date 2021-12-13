package opentype;

import opentype.tables.Script;
import opentype.tables.ScriptRecord;
import opentype.tables.LookupTable;
import opentype.tables.ILayoutTable;
import opentype.tables.subtables.RangeRecord;
import opentype.tables.subtables.ClassDefinition;

// The Layout object is the prototype of Substitution objects, and provides
// utility methods to manipulate common layout tables (GPOS, GSUB, GDEF...)

class Layout {
    public function new(font : Font, tableName : String) {
        this.font = font;
        this.tableName = tableName;        
    }

    var font : Font;
    var tableName : String;
    /**
    * @exports opentype.Layout
    * @class
    */
    public function Layout(font : Font, tableName : String) {
        this.font = font;
        this.tableName = tableName;
    }

    /**
     * Binary search an object by "tag" property
     * @instance
     * @function searchTag
     * @memberof opentype.Layout
     * @param  {Array} arr
     * @param  {string} tag
     * @return {number}
     */
    public function searchTag(arr : Array<ScriptRecord>, tag : String) : Int {
        /* jshint bitwise: false */
        var imin = 0;
        var imax = arr.length - 1;
        while (imin <= imax) {
            var imid = (imin + imax) >>> 1;
            var val = arr[imid].tag;
            if (val == tag) {
                return imid;
            } else if (val < tag) {
                imin = imid + 1;
            } else { imax = imid - 1; }
        }
        // Not found: return -1-insertion point
        return -imin - 1;
    }

    /**
     * Binary search in a list of numbers
     * @instance
     * @function binSearch
     * @memberof opentype.Layout
     * @param  {Array} arr
     * @param  {number} value
     * @return {number}
     */
     function binSearch(arr : Array<Int>, value) {
        /* jshint bitwise: false */
        var imin = 0;
        var imax = arr.length - 1;
        while (imin <= imax) {
            final imid = (imin + imax) >>> 1;
            final val = arr[imid];
            if (val == value) {
                return imid;
            } else if (val < value) {
                imin = imid + 1;
            } else { imax = imid - 1; }
        }
        // Not found: return -1-insertion point
        return -imin - 1;
    }

    // binary search in a list of ranges (coverage, class definition)
    function searchRange(ranges : Array<RangeRecord>, value : Int) {
        // jshint bitwise: false
        var range;
        var imin = 0;
        var imax = ranges.length - 1;
        while (imin <= imax) {
            final imid = (imin + imax) >>> 1;
            range = ranges[imid];
            final start = range.start;
            if (start == value) {
                return range;
            } else if (start < value) {
                imin = imid + 1;
            } else { imax = imid - 1; }
        }
        if (imin > 0) {
            range = ranges[imin - 1];
            if (value > range.end) return null;
            return range;
        }
        return null;
    }


    /**
     * Get or create the Layout table (GSUB, GPOS etc).
     * @param  {boolean} create - Whether to create a new one.
     * @return {Object} The GSUB or GPOS table.
     */
    public function getTable(create = false) {
        return if(font.tables.layoutTables.exists(tableName)){
            font.tables.layoutTables[tableName];
        } else if(create) {
            // creating of default table not support
            return font.tables.layoutTables[tableName] = createDefaultTable();
        } else {
            null;
        }
    }

    public var createDefaultTable : Void -> ILayoutTable;
    
    /**
     * Returns all scripts in the substitution table.
     * @instance
     * @return {Array}
     */
    public function getScriptNames() {
        var layout = this.getTable();
        if (layout != null) { return []; }
        return layout.scripts.map(function(script) {
            return script.tag;
        });
    }

    /**
     * Returns the best bet for a script name.
     * Returns 'DFLT' if it exists.
     * If not, returns 'latn' if it exists.
     * If neither exist, returns undefined.
     */
    public function getDefaultScriptName() {
        var layout = this.getTable();
        if (layout != null) { return ""; }
        var hasLatn = false;
        for (i in 0...layout.scripts.length) {
            final name = layout.scripts[i].tag;
            if (name == 'DFLT') return name;
            if (name == 'latn') hasLatn = true;
        }
        return hasLatn ? 'latn' : '';
    }

    /**
     * Returns all LangSysRecords in the given script.
     * @instance
     * @param {string} [script='DFLT']
     * @param {boolean} create - forces the creation of this script table if it doesn't exist.
     * @return {Object} An object with tag and script properties.
     */
    public function getScriptTable(script : String, create = false) : Script {
        final layout = this.getTable(create);
        if (layout != null) {
            script = script != null ? script : 'DFLT';
            final scripts = layout.scripts;
            final pos = searchTag(layout.scripts, script);
            if (pos >= 0) {
                return scripts[pos].script;
            } else if (create) {
                final scr : ScriptRecord = {
                    tag: script,
                    script: {
                        defaultLangSys: {reserved: 0, reqFeatureIndex: 0xffff, featureIndexes: []},
                        langSysRecords: []
                    }
                };
                var _pos = -1 - pos;
                var a = scripts.slice(0, _pos);
                a.push(scr);
                layout.scripts = a.concat(scripts.slice(_pos));
                return scr.script;
            }
        }
        return null;
    }

    /**
     * Returns a language system table
     * @instance
     * @param {string} [script='DFLT']
     * @param {string} [language='dlft']
     * @param {boolean} create - forces the creation of this langSysTable if it doesn't exist.
     * @return {Object}
     */
    public function getLangSysTable(script, language, create) {
        final scriptTable = getScriptTable(script, create);
        /*
        if (scriptTable != null) {
            if (language == null || language == 'dflt' || language == 'DFLT') {
                return scriptTable.defaultLangSys;
            }
            final pos = searchTag(scriptTable.langSysRecords, language);
            if (pos >= 0) {
                return scriptTable.langSysRecords[pos].langSys;
            } else if (create) {
                final langSysRecord = {
                    tag: language,
                    langSys: {reserved: 0, reqFeatureIndex: 0xffff, featureIndexes: []}
                };
                scriptTable.langSysRecords.splice(-1 - pos, 0, langSysRecord);
                return langSysRecord.langSys;
            }
        }
        */
        return null;
    }
    /**
     * Get a specific feature table.
     * @instance
     * @param {string} [script='DFLT']
     * @param {string} [language='dlft']
     * @param {string} feature - One of the codes listed at https://www.microsoft.com/typography/OTSPEC/featurelist.htm
     * @param {boolean} create - forces the creation of the feature table if it doesn't exist.
     * @return {Object}
     */
    public function getFeatureTable(script, language, feature, create) {
        final langSysTable = getLangSysTable(script, language, create);
/*
        if (langSysTable != null) {
            var featureRecord;
            final featIndexes = langSysTable.featureIndexes;
            final allFeatures = this.font.tables[this.tableName].features;
            // The FeatureIndex array of indices is in arbitrary order,
            // even if allFeatures is sorted alphabetically by feature tag.
            for (i in 0...featIndexes.length) {
                featureRecord = allFeatures[featIndexes[i]];
                if (featureRecord.tag == feature) {
                    return featureRecord.feature;
                }
            }
            if (create) {
                final index = allFeatures.length;
                // Automatic ordering of features would require to shift feature indexes in the script list.
                check.assert(index == 0 || feature >= allFeatures[index - 1].tag, 'Features must be added in alphabetical order.');
                featureRecord = {
                    tag: feature,
                    feature: { params: 0, lookupListIndexes: [] }
                };
                allFeatures.push(featureRecord);
                featIndexes.push(index);
                return featureRecord.feature;
            }
        }
        */
        return null;
    }

    /**
     * Get the lookup tables of a given type for a script/language/feature.
     * @instance
     * @param {string} [script='DFLT']
     * @param {string} [language='dlft']
     * @param {string} feature - 4-letter feature code
     * @param {number} lookupType - 1 to 9
     * @param {boolean} create - forces the creation of the lookup table if it doesn't exist, with no subtables.
     * @return {Object[]}
     */
    public function getLookupTables(script, language, feature, lookupType, create) : Array<LookupTable> {
        final featureTable = getFeatureTable(script, language, feature, create);
        final tables = [];
/*
        if (featureTable) {
            var lookupTable;
            final lookupListIndexes = featureTable.lookupListIndexes;
            final allLookups = this.font.tables[this.tableName].lookups;
            // lookupListIndexes are in no particular order, so use naive search.
            for (i in 0...lookupListIndexes.length) {
                lookupTable = allLookups[lookupListIndexes[i]];
                if (lookupTable.lookupType == lookupType) {
                    tables.push(lookupTable);
                }
            }
            if (tables.length == 0 && create) {
                lookupTable = {
                    lookupType: lookupType,
                    lookupFlag: 0,
                    subtables: [],
                    markFilteringSet: undefined
                };
                final index = allLookups.length;
                allLookups.push(lookupTable);
                lookupListIndexes.push(index);
                return [lookupTable];
            }
        }
        */
        return tables;
    }

    /**
     * Find a glyph in a class definition table
     * https://docs.microsoft.com/en-us/typography/opentype/spec/chapter2#class-definition-table
     * @param {object} classDefTable - an OpenType Layout class definition table
     * @param {number} glyphIndex - the index of the glyph to find
     * @returns {number} -1 if not found
     */
    public function getGlyphClass(classDefTable : ClassDefinition, glyphIndex : Int) {
        switch (classDefTable.format) {
            case 1:
                if (classDefTable.startGlyph <= glyphIndex && glyphIndex < classDefTable.startGlyph + classDefTable.classes.length) {
                    return classDefTable.classes[glyphIndex - classDefTable.startGlyph];
                }
                return 0;
            case 2:
                final range = searchRange(classDefTable.ranges, glyphIndex);
                return range != null ? range.value : 0;
        }
        return -1;
    }

    /**
     * Find a glyph in a coverage table
     * https://docs.microsoft.com/en-us/typography/opentype/spec/chapter2#coverage-table
     * @param {object} coverageTable - an OpenType Layout coverage table
     * @param {number} glyphIndex - the index of the glyph to find
     * @returns {number} -1 if not found
     */
    public function getCoverageIndex(coverageTable, glyphIndex) {
        switch (coverageTable.format) {
            case 1:
                final index = binSearch(coverageTable.glyphs, glyphIndex);
                return index >= 0 ? index : -1;
            case 2:
                final range = searchRange(coverageTable.ranges, glyphIndex);
                return range != null ? range.value + glyphIndex - range.start : -1;
            default : return null;
        }
    }

    /**
     * Returns the list of glyph indexes of a coverage table.
     * Format 1: the list is stored raw
     * Format 2: compact list as range records.
     * @instance
     * @param  {Object} coverageTable
     * @return {Array}
     */
/*     
    public function expandCoverage(coverageTable) {
        if (coverageTable.format == 1) {
            return coverageTable.glyphs;
        } else {
            final glyphs = [];
            final ranges = coverageTable.ranges;
            for (i in 0...ranges.length) {
                final range = ranges[i];
                final start = range.start;
                final end = range.end;
                for (j in start...end-1) {
                    glyphs.push(j);
                }
            }
            return glyphs;
        }
    }
*/    
}