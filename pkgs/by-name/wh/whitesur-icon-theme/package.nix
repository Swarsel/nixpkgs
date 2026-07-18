{
  lib,
  fetchFromGitHub,
  gtk3,
  hicolor-icon-theme,
  jdupes,
  stdenvNoCC,
  alternativeIcons ? false,
  boldPanelIcons ? false,
  themeVariants ? [ ],
}:

let
  pname = "Whitesur-icon-theme";
in
lib.checkListOfEnum "${pname}: theme variants"
  [
    "default"
    "purple"
    "pink"
    "red"
    "orange"
    "yellow"
    "green"
    "grey"
    "nord"
    "all"
  ]
  themeVariants

  stdenvNoCC.mkDerivation
  rec {
    inherit pname;
    version = "2025-12-27";

    src = fetchFromGitHub {
      owner = "vinceliuice";
      repo = "WhiteSur-icon-theme";
      tag = version;
      hash = "sha256-5AWyuqREKpgBCXPplpkdrcInDTZfjVIm/JtTleOmaNY=";
    };

    postPatch = ''
      patchShebangs install.sh
    '';

    nativeBuildInputs = [
      gtk3
      jdupes
    ];

    buildInputs = [ hicolor-icon-theme ];

    installPhase = ''
      runHook preInstall

      ./install.sh --dest $out/share/icons \
        --name WhiteSur \
        --theme ${toString themeVariants} \
        ${lib.optionalString alternativeIcons "--alternative"} \
        ${lib.optionalString boldPanelIcons "--bold"} \

      jdupes --link-soft --recurse $out/share

      runHook postInstall
    '';

    # Drop dangling symlinks from the upstream icon set.
    postFixup = ''
      find $out/share/icons -xtype l -delete
    '';

    dontDropIconThemeCache = true;
    # These fixup steps are slow and unnecessary
    dontPatchELF = true;
    dontRewriteSymlinks = true;

    meta = {
      description = "MacOS Big Sur style icon theme for Linux desktops";
      homepage = "https://github.com/vinceliuice/WhiteSur-icon-theme";
      license = lib.licenses.gpl3Plus;
      maintainers = with lib.maintainers; [ icy-thought ];
      platforms = lib.platforms.linux;
    };

  }
