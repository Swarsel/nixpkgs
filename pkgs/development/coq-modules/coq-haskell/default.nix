{
  lib,
  coq,
  mkCoqDerivation,
  ssreflect,
  version ? null,
}:

mkCoqDerivation {

  inherit version;
  pname = "coq-haskell";

  propagatedBuildInputs = [
    coq
    ssreflect
  ];

  defaultVersion = if lib.versions.range "8.5" "8.8" coq.coq-version then "20171215" else null;
  enableParallelBuilding = false;
  extraInstallFlags = [ "-f Makefile.coq" ];
  mlPlugin = true;
  owner = "jwiegley";
  release."20171215".hash = "sha256:09dq1vvshhlhgjccrhqgbhnq2hrys15xryfszqq11rzpgvl2zgdv";
  release."20171215".rev = "e2cf8b270c2efa3b56fab1ef6acc376c2c3de968";

  meta = {
    description = "Library for formalizing Haskell types and functions in Coq";
    maintainers = with lib.maintainers; [ jwiegley ];
  };
}
