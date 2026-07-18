{
  lib,
  coq,
  mkCoqDerivation,
  stdlib,
  version ? null,
}:

mkCoqDerivation {
  inherit version;
  pname = "bbv";
  propagatedBuildInputs = [ stdlib ];

  defaultVersion =
    let
      inherit (lib.versions) range;
    in
    lib.switch coq.coq-version [
      {
        case = range "8.16" "8.19";
        out = "1.5";
      }
    ] null;

  owner = "mit-plv";

  release = {
    "1.5".hash = "sha256-8/VPsfhNpuYpLmLC/hWszDhgvS6n8m7BRxUlea8PSUw=";
  };

  releaseRev = v: "v${v}";

  meta = {
    description = "Implementation of bitvectors in Coq";
    license = lib.licenses.mit;
  };
}
