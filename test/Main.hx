
import buddy.*;
using buddy.Should;

@colorize
class Main implements Buddy<[
    TestParser,
    tables.GposTable,
    tables.LocaTable,
    TestLayout,
    TestOpenType
]> {}