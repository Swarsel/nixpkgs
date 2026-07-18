{
  lib,
  buildRebar3,
  fetchHex,
}:

buildRebar3 rec {
  version = "0.12.1";

  src = fetchHex {
    inherit version;
    sha256 = "1f174fb6h2071wr7qbw9aqqvnglzsjlylmyi8215fhrmi38w94b6";
    pkg = name;
  };

  name = "rebar3_proper";

  meta = {
    description = "rebar3 proper plugin";
    homepage = "https://github.com/ferd/rebar3_proper";
    license = lib.licenses.bsd3;
  };
}
