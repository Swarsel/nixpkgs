{
  lib,
  fetchFromGitHub,
  gtk3,
  hicolor-icon-theme,
  jdupes,
  stdenvNoCC,
  unstableGitUpdater,
  colorVariants ? [ ], # default is all
  themeVariants ? [ ], # default is all
}:

let
  pname = "qogir-icon-theme";

in
lib.checkListOfEnum "${pname}: color variants" [ "standard" "dark" "all" ] colorVariants
  lib.checkListOfEnum
  "${pname}: theme variants"
  [ "default" "manjaro" "ubuntu" "all" ]
  themeVariants

  stdenvNoCC.mkDerivation
  {
    inherit pname;
    version = "0-unstable-2025-11-04";

    src = fetchFromGitHub {
      owner = "vinceliuice";
      repo = "qogir-icon-theme";
      rev = "c633057ba0d27a504b3255144071c9691ed0264a";
      hash = "sha256-VJHhyKk1f/25CNkqNM7+WQqQRdqBNgWD3XrJ+whOcd0=";
    };

    patches = [
      ./2026-03-20-missing-icons.patch
    ];

    postPatch = ''
      patchShebangs install.sh
    '';

    nativeBuildInputs = [
      gtk3
      jdupes
    ];

    propagatedBuildInputs = [ hicolor-icon-theme ];

    installPhase = ''
      runHook preInstall

      mkdir -p $out/share/icons

      name= ./install.sh \
        ${lib.optionalString (themeVariants != [ ]) ("--theme " + toString themeVariants)} \
        ${lib.optionalString (colorVariants != [ ]) ("--color " + toString colorVariants)} \
        --dest $out/share/icons

      jdupes --quiet --link-soft --recurse $out/share

      runHook postInstall
    '';

    dontDropIconThemeCache = true;
    # These fixup steps are slow and unnecessary.
    dontPatchELF = true;
    dontRewriteSymlinks = true;
    passthru.updateScript = unstableGitUpdater { hardcodeZeroVersion = true; };

    meta = {
      description = "Flat colorful design icon theme";
      homepage = "https://github.com/vinceliuice/Qogir-icon-theme";
      license = with lib.licenses; [ gpl3Only ];
      maintainers = with lib.maintainers; [ romildo ];
      platforms = lib.platforms.linux;
    };
  }
