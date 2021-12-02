package opentype;

class Check {
    public static function assert(predicate : Bool, message : String) {
        if (!predicate) {
            throw (message);
        }
    }

}