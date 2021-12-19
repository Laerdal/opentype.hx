# opentype.hx
Cross platfrom Opentype support library for Haxe. 
The idea of Opentype.hx is to port of https://github.com/opentypejs/opentype.js and deliver a platform independent font library.

Current release is the initial Alpha release

## Getting started

1) Install the lib:

`haxelib install opentype.hx`

2) Create a file called **Main.hx**:

```haxe
import opentype.OpenType;
import opentype.Font;
import haxe.io.Bytes;

class Main {
    static function main() {
        var fontBytes : Bytes;
        OpenType.loadFromFile("path/to/truetype-font.ttf", (b) -> {
            fontBytes = b;
            var font : Font;
            font = OpenType.parse(fontBytes);
        }, (e) -> { trace(e); }
        );
    }
}
```

3) Compile to eg. JavaScript for Nodejs by creating file build.hxml with the following content:

```hxml
-lib opentype.hx
-lib hxnodejs
--js js/app.js
--main Main
```

4) And build it with the commmand:

```cmd
haxe build.hxml
```

