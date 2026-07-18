{
  lib,
  fetchFromGitHub,
  installFonts,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation {
  pname = "oswald";
  version = "4.103";

  src = fetchFromGitHub {
    owner = "googlefonts";
    repo = "OswaldFont";
    rev = "89795261ac9eeb9aa8cd99f43982c4e4b0e53261";
    hash = "sha256-yoUduWHuuKDQaJnQ+CgeMw1vp2lgn/OVPokSDzEU7yk=";
  };

  outputs = [
    "out"
    "webfont"
  ];

  nativeBuildInputs = [ installFonts ];
  preInstall = "rm -r legacy/";

  installPhase = ''
    runHook preInstall
    runHook postInstall
  '';

  meta = {
    description = "Reworking of the classic gothic typeface style";

    longDescription = ''
      Oswald is a reworking of the classic gothic typeface style
      historically represented by designs such as 'Alternate Gothic'.
      The characters of Oswald have been re-drawn and reformed to
      better fit the pixel grid of standard digital screens.
    '';

    homepage = "https://github.com/googlefonts/OswaldFont";
    license = lib.licenses.ofl;
    maintainers = with lib.maintainers; [ mimvoid ];
    platforms = lib.platforms.all;
  };
}
