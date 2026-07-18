{
  lib,
  stdenv,
  fetchFromGitHub,
  libarchive,
  openssl,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "makerpm";
  version = "1.0";

  src = fetchFromGitHub {
    owner = "ivan-tkatchev";
    repo = "makerpm";
    rev = finalAttrs.version;
    sha256 = "089dkbh5705ppyi920rd0ksjc0143xmvnhm8qrx93rsgwc1ggi1y";
  };

  buildInputs = [
    zlib
    libarchive
    openssl
  ];

  installPhase = ''
    mkdir -p $out/bin
    cp makerpm $out/bin
  '';

  meta = {
    description = "Clean, simple RPM packager reimplemented completely from scratch";
    homepage = "https://github.com/ivan-tkatchev/makerpm/";
    license = lib.licenses.free;
    maintainers = [ ];
    platforms = lib.platforms.all;
    mainProgram = "makerpm";
  };
})
