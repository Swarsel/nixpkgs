{ fetchurl }:
let
  fetchTestInput =
    { hash, res }:
    fetchurl {
      inherit hash;
      name = builtins.replaceStrings [ "/" ] [ "__" ] res;
      url = "https://www.mkgmap.org.uk/testinput/${res}";
    };
in
[
  (fetchTestInput {
    hash = "sha256-9d7DL1+wMVjve/4S/VXbe6wjaJFusfDyfn0FFc4uq0I=";
    res = "osm/alaska-2016-12-27.osm.pbf";
  })
  (fetchTestInput {
    hash = "sha256-TmvZHZgPevnwOtSB2H8BiYvoxnYpYRKC+KPyrRTxdiE=";
    res = "osm/hamburg-2016-12-26.osm.pbf";
  })
]
