{
  lib,
  fetchFromGitHub,
  stdenvNoCC,
}:

let
  version = "0.91.12";
in
stdenvNoCC.mkDerivation {
  inherit version;
  pname = "open-dyslexic";

  src = fetchFromGitHub {
    owner = "antijingoist";
    repo = "opendyslexic";
    rev = "v${version}";
    hash = "sha256-a8hh8NGt5djj9EC7ChO3SnnjuYMOryzbHWTK4gC/vIw=";
  };

  installPhase = ''
    runHook preInstall

    install -Dm644 compiled/*.otf -t $out/share/fonts/opentype

    runHook postInstall
  '';

  meta = {
    description = "Font created to increase readability for readers with dyslexia";
    homepage = "https://opendyslexic.org/";
    license = lib.licenses.ofl;
    maintainers = [ lib.maintainers.rycee ];
    platforms = lib.platforms.all;
  };
}
