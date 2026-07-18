{
  lib,
  stdenv,
  fetchFromGitHub,
  libpng,
  pkg-config,
}:
let
  version = "1.0.1";
in
stdenv.mkDerivation {
  inherit version;
  pname = "guetzli";

  src = fetchFromGitHub {
    owner = "google";
    repo = "guetzli";
    rev = "v${version}";
    sha256 = "1wy9wfvyradp0aigfv8yijvj0dgb5kpq2yf2xki15f605jc1r5dm";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ libpng ];

  installPhase = ''
    mkdir -p $out/bin
    install bin/Release/guetzli $out/bin/
  '';

  meta = {
    description = "Perceptual JPEG encoder";
    longDescription = "Guetzli is a JPEG encoder that aims for excellent compression density at high visual quality.";
    homepage = "https://github.com/google/guetzli";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.seppeljordan ];
    platforms = lib.platforms.x86_64;
    mainProgram = "guetzli";
  };
}
