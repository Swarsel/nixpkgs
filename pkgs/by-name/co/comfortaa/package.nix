{
  lib,
  fetchFromGitHub,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation {
  pname = "comfortaa";
  version = "unstable-2021-07-29";

  src = fetchFromGitHub {
    owner = "googlefonts";
    repo = "comfortaa";
    rev = "2a87ac6f6ea3495150bfa00d0c0fb53dd0a2f11b";
    hash = "sha256-4ZBRaQyYlnt9l4NgBHezuCnR3rKTJ37L41RTbGAhd0M=";

    postFetch = ''
      # Remove the OTF fonts as they are not needed and cause a hash mismatch
      rm -rf $out/fonts/{OTF,otf}
    '';
  };

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/fonts/truetype $out/share/doc/comfortaa
    cp fonts/TTF/*.ttf $out/share/fonts/truetype
    cp FONTLOG.txt README.md $out/share/doc/comfortaa

    runHook postInstall
  '';

  dontBuild = true;

  meta = {
    description = "Clean and modern font suitable for headings and logos";
    homepage = "http://aajohan.deviantart.com/art/Comfortaa-font-105395949";
    license = lib.licenses.ofl;
    maintainers = [ lib.maintainers.rycee ];
    platforms = lib.platforms.all;
  };
}
