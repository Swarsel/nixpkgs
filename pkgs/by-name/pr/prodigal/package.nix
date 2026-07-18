{
  lib,
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "prodigal";
  version = "2.6.3";

  src = fetchFromGitHub {
    owner = "hyattpd";
    repo = "Prodigal";
    rev = "v${finalAttrs.version}";
    sha256 = "1fs1hqk83qjbjhrvhw6ni75zakx5ki1ayy3v6wwkn3xvahc9hi5s";
  };

  makeFlags = [
    "CC=${stdenv.cc.targetPrefix}cc"
    "INSTALLDIR=$(out)/bin"
  ];

  meta = {
    description = "Fast, reliable protein-coding gene prediction for prokaryotic genomes";
    homepage = "https://github.com/hyattpd/Prodigal";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ luispedro ];
    platforms = lib.platforms.all;
    mainProgram = "prodigal";
  };
})
