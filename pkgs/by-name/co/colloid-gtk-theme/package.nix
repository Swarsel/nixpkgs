{
  lib,
  fetchFromGitHub,
  gtk-engine-murrine,
  jdupes,
  sassc,
  stdenvNoCC,
  colorVariants ? [ ], # default: all
  sizeVariants ? [ ], # default: standard
  themeVariants ? [ ], # default: blue
  tweaks ? [ ],
}:

let
  pname = "colloid-gtk-theme";

in
lib.checkListOfEnum "colloid-gtk-theme: theme variants"
  [
    "default"
    "purple"
    "pink"
    "red"
    "orange"
    "yellow"
    "green"
    "teal"
    "grey"
    "all"
  ]
  themeVariants
  lib.checkListOfEnum
  "colloid-gtk-theme: color variants"
  [ "standard" "light" "dark" ]
  colorVariants
  lib.checkListOfEnum
  "colloid-gtk-theme: size variants"
  [ "standard" "compact" ]
  sizeVariants
  lib.checkListOfEnum
  "colloid-gtk-theme: tweaks"
  [
    "nord"
    "dracula"
    "gruvbox"
    "everforest"
    "catppuccin"
    "all"
    "black"
    "rimless"
    "normal"
    "float"
  ]
  tweaks

  stdenvNoCC.mkDerivation
  (finalAttrs: {
    inherit pname;
    version = "2025-07-31";

    src = fetchFromGitHub {
      owner = "vinceliuice";
      repo = "colloid-gtk-theme";
      tag = finalAttrs.version;
      hash = "sha256-0pXbeeBAkk6v2DBWfUYhWWdyrQhgr/JfDbhyS33maMM=";
    };

    postPatch = ''
      patchShebangs install.sh
    '';

    nativeBuildInputs = [
      jdupes
      sassc
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
      homepage = "https://github.com/vinceliuice/Colloid-gtk-theme";
      license = lib.licenses.gpl3Only;
      maintainers = [ lib.maintainers.romildo ];
      platforms = lib.platforms.unix;
    };
  })
