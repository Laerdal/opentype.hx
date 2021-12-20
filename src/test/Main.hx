
import buddy.*;
using buddy.Should;

@colorize
class Main implements Buddy<[
    TestParser,
    tables.GposTable,
    tables.LocaTable,
    tables.LtagTable,
    tables.NameTable,
    Table,
    TestLayout,
    TestOpenType,
    TestTypes,
    utils.TestGlyphMetrics
]> {}