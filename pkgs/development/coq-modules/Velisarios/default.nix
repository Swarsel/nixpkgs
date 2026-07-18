{
  lib,
  coq,
  mkCoqDerivation,
  version ? null,
}:

mkCoqDerivation {
  inherit version;
  pname = "Velisarios";
  preBuild = "./create-makefile.sh";
  buildPhase = "make -j$NIX_BUILD_CORES";

  installPhase = ''
    mkdir -p $out/lib/coq/${coq.coq-version}/Velisarios
    cp -pR model/*.vo $out/lib/coq/${coq.coq-version}/Velisarios
  '';

  defaultVersion = if lib.versions.range "8.6" "8.8" coq.coq-version then "20180221" else null;
  mlPlugin = true;
  owner = "vrahli";
  release."20180221".hash = "sha256:0l9885nxy0n955fj1gnijlxl55lyxiv9yjfmz8hmfrn9hl8vv1m2";
  release."20180221".rev = "e1eee1f10d5d46331a560bd8565ac101229d0d6b";
}
