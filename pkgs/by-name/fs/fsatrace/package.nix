{
  lib,
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation rec {
  pname = "fsatrace";
  version = "0.0.5";

  src = fetchFromGitHub {
    owner = "jacereda";
    repo = "fsatrace";
    rev = "5af79511828ca6cea4e5dd9f28e1676fb0b705e9";
    "hash" = "sha256-pn07qlrRaM153znEviziuKWrkX9cLsNFCujovmE4UUA=";
  };

  makeFlags = [ "INSTALLDIR=$(out)/$(installDir)" ];

  preInstall = ''
    mkdir -p $out/$installDir
  '';

  postInstall = ''
    mkdir -p $out/bin
    ln -s $out/$installDir/fsatrace $out/bin/fsatrace
  '';

  installDir = "libexec/${pname}-${version}";

  meta = {
    description = "Filesystem access tracer";
    homepage = "https://github.com/jacereda/fsatrace";
    license = lib.licenses.isc;
    platforms = lib.platforms.linux;
    mainProgram = "fsatrace";
  };
}
