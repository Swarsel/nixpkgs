{
  lib,
  buildRebar3,
  fetchHex,
}:

buildRebar3 rec {
  version = "1.15.0";

  src = fetchHex {
    inherit version;
    sha256 = "sha256-TA+tT2Q3yuNT1RfaIY/ng0e4/6RLmBeIdJTKquVFlbM=";
    pkg = name;
  };

  name = "pc";

  meta = {
    description = "Rebar3 port compiler for native code";
    homepage = "https://github.com/blt/port_compiler";
    license = lib.licenses.mit;
  };
}
