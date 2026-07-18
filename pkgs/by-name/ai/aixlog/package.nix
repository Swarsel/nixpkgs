{
  lib,
  fetchFromGitHub,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "aixlog";
  version = "1.5.0";

  src = fetchFromGitHub {
    owner = "badaix";
    repo = "aixlog";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Xhle7SODRZlHT3798mYIzBi1Mqjz8ai74/UnbVWetiY=";
  };

  installPhase = ''
    runHook preInstall

    install -Dm644 $src/include/aixlog.hpp $out/include/aixlog.hpp

    runHook postInstall
  '';

  dontBuild = true;
  dontConfigure = true;
  dontFixup = true;

  meta = {
    description = "Header-only C++ logging library";
    homepage = "https://github.com/badaix/aixlog";
    changelog = "https://github.com/badaix/aixlog/releases/tag/${finalAttrs.src.rev}";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
})
