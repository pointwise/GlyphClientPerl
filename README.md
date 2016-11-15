# GlyphClientPerl
Perl implementation of a client which communicates with the Pointwise Glyph Server.

Example usage:

```perl
use Pointwise::GlyphClient;

$glf = new Pointwise::GlyphClient();
if ($glf->connect()) {
    $result = $glf->eval("pw::Application getVersion");
    print "Pointwise version is " . $result . "\n";
}
elsif ($glf->is_busy()) {
    print "Pointwise is busy\n";
}
elsif ($glf->auth_failed()) {
    print "Pointwise connection not authenticated\n";
}
else {
    print "Pointwise connection failed\n";
}
```