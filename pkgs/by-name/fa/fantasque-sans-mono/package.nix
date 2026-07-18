{
  lib,
  fetchzip,
  installFonts,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "fantasque-sans-mono";
  version = "1.8.0";

  src = fetchzip {
    url = "https://github.com/belluzj/fantasque-sans/releases/download/v${finalAttrs.version}/FantasqueSansMono-Normal.zip";
    hash = "sha256-MNXZoDPi24xXHXGVADH16a3vZmFhwX0Htz02+46hWFc=";
    stripRoot = false;
  };

  outputs = [
    "out"
    "webfont"
    "doc"
  ];

  nativeBuildInputs = [ installFonts ];

  installPhase = ''
    runHook preInstall

    install -m644 -Dt $doc/share/doc/${finalAttrs.pname}-${finalAttrs.version} {*.md,*.txt}

    runHook postInstall
  '';

  meta = {
    description = "Font family with a great monospaced variant for programmers";
    homepage = "https://github.com/belluzj/fantasque-sans";
    license = lib.licenses.ofl;
    maintainers = [ lib.maintainers.rycee ];
    platforms = lib.platforms.all;
  };
})
