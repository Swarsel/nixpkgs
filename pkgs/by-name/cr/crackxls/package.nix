{
  lib,
  stdenv,
  fetchFromGitHub,
  autoconf,
  automake,
  gmp,
  libgsf,
  openssl,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "crackxls";
  version = "1.0";

  src = fetchFromGitHub {
    owner = "GavinSmith0123";
    repo = "crackxls2003";
    tag = "v${finalAttrs.version}";
    sha256 = "sha256-CJFC4iKHHpSRQBdotmum7NjpPNUjbB6cSCs5HMXnjO8=";
  };

  nativeBuildInputs = [
    pkg-config
    autoconf
    automake
  ];

  buildInputs = [
    openssl
    libgsf
    gmp
  ];

  installPhase = ''
    mkdir -p $out/bin
    cp crackxls2003 $out/bin/
  '';

  meta = {
    description = "Used to break the encryption on old Microsoft Excel and Microsoft Word files";
    homepage = "https://github.com/GavinSmith0123/crackxls2003/";
    license = lib.licenses.gpl3;
    platforms = lib.platforms.linux;
    mainProgram = "crackxls2003";
  };
})
