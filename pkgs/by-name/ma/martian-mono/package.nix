{
  lib,
  fetchzip,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation rec {
  pname = "martian-mono";
  version = "1.1.0";

  src = fetchzip {
    url = "https://github.com/evilmartians/mono/releases/download/v${version}/martian-mono-${version}-otf.zip";
    sha256 = "sha256-W6ewNtFDS1O1fwoAe27tIgNZn7AAKo965dWkZYzsg+o=";
    stripRoot = false;
  };

  doCheck = false;

  installPhase = ''
    runHook preInstall

    install -Dm644 -t $out/share/fonts/opentype/ *.otf

    runHook postInstall
  '';

  dontBuild = true;
  dontConfigure = true;
  dontFixup = true;
  dontPatch = true;

  meta = {
    description = "Free and open-source monospaced font from Evil Martians";
    homepage = "https://github.com/evilmartians/mono";
    changelog = "https://github.com/evilmartians/mono/raw/v${version}/Changelog.md";
    license = lib.licenses.ofl;
    maintainers = [ ];
    platforms = lib.platforms.all;
  };
}
