package opentype;

@:structInit
class Pair<T,S> {
    public function new(value1 : T, value2 : S) {
        this.value1 = value1;
        this.value2 = value2;
    }

    public var value1 : T;
    public var value2 : S;
}