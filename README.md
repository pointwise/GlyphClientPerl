# GlyphClientPerl
Copyright 2021 Cadence Design Systems, Inc. All rights reserved worldwide.

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

## Disclaimer
This file is licensed under the Cadence Public License Version 1.0 (the "License"), a copy of which is found in the LICENSE file, and is distributed "AS IS." 
TO THE MAXIMUM EXTENT PERMITTED BY APPLICABLE LAW, CADENCE DISCLAIMS ALL WARRANTIES AND IN NO EVENT SHALL BE LIABLE TO ANY PARTY FOR ANY DAMAGES ARISING OUT OF OR RELATING TO USE OF THIS FILE. 
Please see the License for the full text of applicable terms.