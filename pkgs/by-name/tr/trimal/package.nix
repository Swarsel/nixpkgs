{
  lib,
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "trimal";
  version = "1.5.1";

  src = fetchFromGitHub {
    owner = "scapella";
    repo = "trimal";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-ONSkYceCgYGSpABj0iOx6yj2hMyFHqCHflYRW+Q6RVc=";
  };

  installPhase = ''
    mkdir -p $out/bin
    cp -a trimal readal statal $out/bin
  '';

  postUnpack = ''
    sourceRoot=''${sourceRoot}/source
    echo Source root reset to ''${sourceRoot}
  '';

  meta = {
    description = "Tool for the automated removal of spurious sequences or poorly aligned regions from a multiple sequence alignment";
    homepage = "http://trimal.cgenomics.org";
    license = lib.licenses.gpl3;
    maintainers = [ lib.maintainers.bzizou ];
    platforms = lib.platforms.linux;
  };
})
