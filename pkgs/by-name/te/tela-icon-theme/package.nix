{
  lib,
  fetchFromGitHub,
  adwaita-icon-theme,
  gtk3,
  hicolor-icon-theme,
  jdupes,
  kdePackages,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation rec {
  pname = "tela-icon-theme";
  version = "2025-02-10";

  src = fetchFromGitHub {
    owner = "vinceliuice";
    repo = "tela-icon-theme";
    rev = version;
    hash = "sha256-ufjKFlKJnmNwD2m1w+7JSBQij6ltxXWCpUEvVxECS98=";
  };

  nativeBuildInputs = [
    gtk3
    jdupes
  ];

  propagatedBuildInputs = [
    adwaita-icon-theme
    kdePackages.breeze-icons
    hicolor-icon-theme
  ];

  installPhase = ''
    runHook preInstall

    patchShebangs install.sh
    mkdir -p $out/share/icons
    ./install.sh -a -d $out/share/icons
    jdupes -l -r $out/share/icons

    runHook postInstall
  '';

  dontCheckForBrokenSymlinks = true;
  dontDropIconThemeCache = true;
  # These fixup steps are slow and unnecessary.
  dontPatchELF = true;
  dontRewriteSymlinks = true;
  dontWrapQtApps = true;

  meta = {
    description = "Flat colorful Design icon theme";
    homepage = "https://github.com/vinceliuice/tela-icon-theme";
    changelog = "https://github.com/vinceliuice/Tela-icon-theme/releases/tag/${src.rev}";
    license = lib.licenses.gpl3Only;
    maintainers = [ ];
    # darwin systems use case-insensitive filesystems that cause hash mismatches
    platforms = lib.subtractLists lib.platforms.darwin lib.platforms.unix;
  };
}
