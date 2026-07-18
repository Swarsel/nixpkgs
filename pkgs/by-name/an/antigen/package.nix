{
  lib,
  stdenv,
  fetchurl,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "antigen";
  version = "2.2.3";

  src = fetchurl {
    url = "https://github.com/zsh-users/antigen/releases/download/v${finalAttrs.version}/antigen.zsh";
    sha256 = "1bmp3qf14509swpxin4j9f98n05pdilzapjm0jdzbv0dy3hn20ix";
  };

  strictDeps = true;

  installPhase = ''
    outdir=$out/share/antigen
    mkdir -p $outdir
    cp $src $outdir/antigen.zsh
  '';

  dontUnpack = true;

  meta = {
    description = "Plugin manager for zsh";
    homepage = "https://antigen.sharats.me/";
    license = lib.licenses.mit;
  };
})
