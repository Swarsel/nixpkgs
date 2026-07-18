{
  lib,
  coq,
  mkCoqDerivation,
  stdlib,
  version ? null,
}:

mkCoqDerivation {
  inherit version;
  pname = "LibHyps";
  propagatedBuildInputs = [ stdlib ];
  configureScript = "./configure.sh";
  defaultVersion = if (lib.versions.range "8.11" "9.0") coq.version then "2.0.8" else null;
  owner = "Matafou";

  release = {
    "2.0.8".hash = "sha256-u8T7ZWfgYNFBsIPss0uUS0oBvdlwPp3t5yYIMjYzfLc=";
  };

  releaseRev = (v: "libhyps-${v}");

  meta = {
    description = "Hypotheses manipulation library";
    license = lib.licenses.mit;
  };
}
