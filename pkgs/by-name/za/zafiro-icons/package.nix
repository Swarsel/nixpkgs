{
  lib,
  fetchFromGitHub,
  gitUpdater,
  gnome-icon-theme,
  gtk3,
  hicolor-icon-theme,
  jdupes,
  kdePackages,
  numix-icon-theme,
  numix-icon-theme-circle,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "zafiro-icons";
  version = "1.3";

  src = fetchFromGitHub {
    owner = "zayronxio";
    repo = "zafiro-icons";
    tag = finalAttrs.version;
    hash = "sha256-IbFnlUOSADYMNMfvRuRPndxcQbnV12BqMDb9bJRjnoU=";
  };

  nativeBuildInputs = [
    gtk3
    jdupes
  ];

  propagatedBuildInputs = [
    kdePackages.breeze-icons
    gnome-icon-theme
    numix-icon-theme
    numix-icon-theme-circle
    hicolor-icon-theme
    # still missing parent icon themes: Surfn
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/icons

    for theme in Dark Light; do
      cp -a $theme $out/share/icons/Zafiro-icons-$theme

      # remove unneeded files
      rm $out/share/icons/Zafiro-icons-$theme/_config.yml

      # remove files with non-ascii characters in name
      # https://github.com/zayronxio/Zafiro-icons/issues/111
      rm $out/share/icons/Zafiro-icons-$theme/apps/scalable/βTORRENT.svg

      gtk-update-icon-cache $out/share/icons/Zafiro-icons-$theme
    done

    jdupes --link-soft --recurse $out/share

    runHook postInstall
  '';

  dontDropIconThemeCache = true;
  dontPatchELF = true;
  dontRewriteSymlinks = true;
  dontWrapQtApps = true;
  passthru.updateScript = gitUpdater { };

  meta = {
    description = "Icon pack flat with light colors";
    homepage = "https://github.com/zayronxio/Zafiro-icons";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ romildo ];
    platforms = lib.platforms.linux;
  };
})
