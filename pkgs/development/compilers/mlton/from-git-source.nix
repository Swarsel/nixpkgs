{
  lib,
  stdenv,
  fetchgit,
  gmp,
  hash,
  mltonBootstrap,
  rev,
  version,
  which,
  doCheck ? true,
  url ? "https://github.com/mlton/mlton",
}:

stdenv.mkDerivation {
  inherit version doCheck;
  pname = "mlton";

  src = fetchgit {
    inherit url rev hash;
  };

  strictDeps = true;

  nativeBuildInputs = [
    which
    mltonBootstrap
  ];

  buildInputs = [ gmp ];

  preBuild = ''
    find . -type f | grep -v -e '\.tgz''$' | xargs sed -i "s@/usr/bin/env bash@$(type -p bash)@"
    sed -i "s|/tmp|$TMPDIR|" bin/regression

    makeFlagsArray=(
      MLTON_VERSION="${version} ${rev}"
      CC="$(type -p cc)"
      PREFIX="$out"
      WITH_GMP_INC_DIR="${gmp.dev}/include"
      WITH_GMP_LIB_DIR="${gmp}/lib"
      )
  '';

  # build fails otherwise
  enableParallelBuilding = false;
  meta = import ./meta.nix { inherit lib; };
}
