{
  lib,
  fetchurl,
  gitUpdater,
  gtk-engine-murrine,
  jdupes,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation rec {
  pname = "theme-obsidian2";
  version = "2.25";

  src = fetchurl {
    url = "https://github.com/madmaxms/theme-obsidian-2/releases/download/v${version}/obsidian-2-theme.tar.xz";
    sha256 = "sha256-Hajz2bFcsi+9kSjxuZ6Jav8t7S6trDUF5yJivw+Vypw=";
  };

  nativeBuildInputs = [
    jdupes
  ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/themes
    cp -a Obsidian-2* $out/share/themes
    jdupes --quiet --link-soft --recurse $out/share
    runHook postInstall
  '';

  propagatedUserEnvPkgs = [
    gtk-engine-murrine
  ];

  sourceRoot = ".";

  passthru.updateScript = gitUpdater {
    rev-prefix = "v";
    url = "https://github.com/madmaxms/theme-obsidian-2";
  };

  meta = {
    description = "Gnome theme based upon Adwaita-Maia dark skin";
    homepage = "https://github.com/madmaxms/theme-obsidian-2";
    license = with lib.licenses; [ gpl3Only ];
    maintainers = [ lib.maintainers.romildo ];
    platforms = lib.platforms.linux;
  };
}
