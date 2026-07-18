{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  ghostscript,
  pkg-config,
  poppler,
  texliveMinimal,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "extractpdfmark";
  version = "1.1.1";

  src = fetchFromGitHub {
    owner = "trueroad";
    repo = "extractpdfmark";
    rev = "v${finalAttrs.version}";
    hash = "sha256-pNc/SWAtQWMbB2+lIQkJdBYSZ97iJXK71mS59qQa7Hs=";
  };

  patches = [
    ./gettext-0.25.patch
  ];

  strictDeps = true;

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];

  buildInputs = [
    poppler
  ];

  env = lib.optionalAttrs stdenv.hostPlatform.isDarwin {
    NIX_LDFLAGS = "-liconv";
  };

  doCheck = true;

  nativeCheckInputs = [
    ghostscript
    texliveMinimal
  ];

  meta = {
    description = "Extract page mode and named destinations as PDFmark from PDF";
    homepage = "https://github.com/trueroad/extractpdfmark";
    license = lib.licenses.gpl3Plus;
    maintainers = [ lib.maintainers.samueltardieu ];
    platforms = lib.platforms.all;
    mainProgram = "extractpdfmark";
  };
})
