package opentype.utils;

#if js
import js.lib.Map;

abstract FastIntMap<V>(js.lib.Map<Int,V>) {
    public inline function new() {
        this = new js.lib.Map();
    }

    @:arrayAccess
    public inline function get(k : Int) : V {
        return this.get(k);
    }
    
    @:arrayAccess
    public inline function set(k : Int, v : V) {
        this.set(k, v);
    }

    public inline function exists(k : Int) : Bool {
        return this.has(k);
    }
}
#else
abstract FastIntMap<V>(Map<Int,V>) {
    public inline function new() {
        this = [];
    }

    @:arrayAccess
    public inline function get(k : Int) : V {
        return this.get(k);
    }
    
    @:arrayAccess
    public inline function set(k : Int, v : V) {
        this[k] = v;
    }

    public inline function exists(k : Int) : Bool {
        return this.exists(k);
    }
}
#end