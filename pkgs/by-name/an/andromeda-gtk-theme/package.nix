{
  lib,
  fetchFromGitHub,
  gtk-engine-murrine,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation {
  pname = "andromeda-gtk-theme";
  version = "0-unstable-2024-06-24";

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/themes
    cp -a Andromeda* $out/share/themes

    # remove uneeded files, which are not distributed in https://www.gnome-look.org/p/2039961/
    rm -rf $out/share/themes/*/.gitignore
    rm -rf $out/share/themes/*/Art
    rm -rf $out/share/themes/*/LICENSE
    rm -rf $out/share/themes/*/README.md
    rm -rf $out/share/themes/*/{package.json,package-lock.json,Gulpfile.js}
    rm -rf $out/share/themes/*/src
    rm -rf $out/share/themes/*/cinnamon/*.scss
    rm -rf $out/share/themes/*/gnome-shell/{earlier-versions,extensions,*.scss}
    rm -rf $out/share/themes/*/gtk-2.0/{assets.svg,assets.txt,links.fish,render-assets.sh}
    rm -rf $out/share/themes/*/gtk-3.0/{apps,widgets,*.scss}
    rm -rf $out/share/themes/*/gtk-4.0/{apps,widgets,*.scss}
    rm -rf $out/share/themes/*/xfwm4/{assets,render_assets.fish}

    runHook postInstall
  '';

  propagatedUserEnvPkgs = [
    gtk-engine-murrine
  ];

  sourceRoot = ".";

  srcs = [
    (fetchFromGitHub {
      hash = "sha256-YzmNo7WZjF/BLKgT2wJXk0ms8bb5AydFcfPzFmRrhkU=";
      name = "Andromeda";
      owner = "EliverLara";
      repo = "Andromeda-gtk";
      rev = "1d86d5cab146a1841bfe2e5c4f0a109b315cfd98";
    })

    (fetchFromGitHub {
      hash = "sha256-Bi5G3zs1bFYbOf74864eZHPUIJvBbByQNtDfqkNUSxo=";
      name = "Andromeda-standard-buttons";
      owner = "EliverLara";
      repo = "Andromeda-gtk";
      rev = "7b0f5508269695054306eec10bd56ef5598ddf4a";
    })
  ];

  meta = {
    description = "Elegant dark theme for gnome, mate, budgie, cinnamon, xfce";
    homepage = "https://github.com/EliverLara/Andromeda-gtk";
    license = lib.licenses.gpl3Only;

    maintainers = with lib.maintainers; [
      jakedevs
      romildo
    ];

    platforms = lib.platforms.linux;
  };
}
