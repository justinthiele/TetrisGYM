const {
    writeRLE,
    drawTiles,
    drawAttrs,
    flatLookup,
} = require('./nametables');

const buffer = Array.from({ length: 1024 }, () => 0xFF);

const lookup = flatLookup(`
0123456789ABCDEF
GHIJKLMNOPQRSTUV
WXYZ-.˙>!^()####
########qweadzxc
################
################
################
################
################
################
################
################
################
################
############?£##
###############
`);

drawTiles(buffer, lookup, `
                               #
                               #
                               #
                               #
                               #
                               #
                               #
                               #
                               #
                               #
                               #
                               #
                               #
                               #
  00£00?                       #
                               #
                               #
                               #
  TAP  0                       #
                               #
                               #
                               #
  DIR                          #
                               #
                               #
                               #
                               #
                               #
                               #
                               #
`);

drawAttrs(buffer, [`
    1111111111112222
    1111111111112222
    1111111111112222
    2222222222222222
    2222222222222222
    1111111111112222
    1111111111112222
    1111111111112222
`,`
    2222000000002222
    0000000000002222
    2222000000002222
    0000000000002222
    0000000000002222
    0000000000002222
    0000000000002222
    0000000000002222
`]);

writeRLE(
    __dirname + '/speedtest_nametable.bin',
    buffer,
);