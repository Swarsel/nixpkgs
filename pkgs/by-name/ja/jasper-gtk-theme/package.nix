{
  lib,
  fetchFromGitHub,
  gnome-themes-extra,
  gtk-engine-murrine,
  jdupes,
  sassc,
  stdenvNoCC,
  colorVariants ? [ ], # default: all
  sizeVariants ? [ ], # default: standard
  themeVariants ? [ ], # default: teal
  tweaks ? [ ],
}:

let
  pname = "jasper-gtk-theme";

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
    "blue"
    "grey"
    "all"
  ]
  themeVariants
  lib.checkListOfEnum
  "${pname}: color variants"
  [ "standard" "light" "dark" ]
  colorVariants
  lib.checkListOfEnum
  "${pname}: size variants"
  [ "standard" "compact" ]
  sizeVariants
  lib.checkListOfEnum
  "${pname}: tweaks"
  [
    "nord"
    "dracula"
    "black"
    "macos"
  ]
  tweaks

  stdenvNoCC.mkDerivation
  {
    inherit pname;
    version = "0-unstable-2025-04-02";

    src = fetchFromGitHub {
      owner = "vinceliuice";
      repo = "Jasper-gtk-theme";
      rev = "71cb99a6618d839b1058cb8e6660a3b2f63aca70";
      hash = "sha256-ZWPUyVszDPUdzttAJuIA9caDpP4SQ7mIbCoczxwvsus=";
    };

    postPatch = ''
      patchShebangs install.sh
    '';

    nativeBuildInputs = [
      jdupes
      sassc
    ];

    buildInputs = [
      gnome-themes-extra
    ];

    installPhase = ''
      runHook preInstall

      name= HOME="$TMPDIR" ./install.sh \
        ${lib.optionalString (themeVariants != [ ]) "--theme " + toString themeVariants} \
        ${lib.optionalString (colorVariants != [ ]) "--color " + toString colorVariants} \
        ${lib.optionalString (sizeVariants != [ ]) "--size " + toString sizeVariants} \
        ${lib.optionalString (tweaks != [ ]) "--tweaks " + toString tweaks} \
        --dest $out/share/themes

      jdupes --quiet --link-soft --recurse $out/share

      runHook postInstall
    '';

    propagatedUserEnvPkgs = [
      gtk-engine-murrine
    ];

    meta = {
      description = "Modern and clean Gtk theme";
      homepage = "https://github.com/vinceliuice/Jasper-gtk-theme";
      license = lib.licenses.gpl3Only;
      maintainers = [ lib.maintainers.romildo ];
      platforms = lib.platforms.unix;
    };
  }
