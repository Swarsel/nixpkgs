{
  lib,
  stdenv,
  fetchFromGitHub,
  libice,
  libsm,
  libx11,
  libxau,
  libxdmcp,
  libxpm,
  libxt,
  sbcl,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "fricas";
  version = "1.3.12";

  src = fetchFromGitHub {
    owner = "fricas";
    repo = "fricas";
    rev = finalAttrs.version;
    sha256 = "sha256-GUGJR65K1bPC0D36l4Yyj3GOsWtUrSKLu6JnlfjHzDc=";
  };

  buildInputs = [
    sbcl
    libx11
    libxpm
    libice
    libsm
    libxt
    libxau
    libxdmcp
  ];

  # Remove when updating to next version
  configurePhase = ''
    runHook preConfigure

    ./configure --prefix=$out --with-lisp='sbcl --dynamic-space-size 3072'

    runHook postConfigure
  '';

  dontStrip = true;

  meta = {
    description = "Advanced computer algebra system";
    homepage = "https://fricas.github.io";
    license = lib.licenses.bsd3;
    maintainers = [ lib.maintainers.sprock ];
    platforms = lib.platforms.linux;
  };
})
