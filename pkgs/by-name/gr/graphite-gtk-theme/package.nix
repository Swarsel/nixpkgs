{
  lib,
  fetchFromGitHub,
  gitUpdater,
  gtk-engine-murrine,
  jdupes,
  sassc,
  stdenvNoCC,
  colorVariants ? [ ], # default: all
  grubScreens ? [ ], # default: 1080p
  sizeVariants ? [ ], # default: standard
  themeVariants ? [ ], # default: blue
  tweaks ? [ ],
  wallpapers ? false,
  withGrub ? false,
}:

let
  pname = "graphite-gtk-theme";

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
    "teal"
    "blue"
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
    "black"
    "darker"
    "rimless"
    "normal"
    "float"
    "colorful"
  ]
  tweaks
  lib.checkListOfEnum
  "${pname}: grub screens"
  [ "1080p" "2k" "4k" ]
  grubScreens

  stdenvNoCC.mkDerivation
  rec {
    inherit pname;
    version = "2025-07-06";

    src = fetchFromGitHub {
      owner = "vinceliuice";
      repo = "graphite-gtk-theme";
      rev = version;
      hash = "sha256-TOIpQTYg+1DX/Tq5BMygxbUC0NpzPWBGDtOnnT55c1w=";
    };

    postPatch = ''
      patchShebangs install.sh wallpaper/install-wallpapers.sh

      substituteInPlace wallpaper/install-wallpapers.sh \
       --replace-fail /usr/share $out/share \
       --replace-fail '[[ "$UID" -eq "$ROOT_UID" ]]' true
    '';

    nativeBuildInputs = [
      jdupes
      sassc
    ];

    installPhase = ''
      runHook preInstall

      name= ./install.sh \
        ${lib.optionalString (themeVariants != [ ]) "--theme " + toString themeVariants} \
        ${lib.optionalString (colorVariants != [ ]) "--color " + toString colorVariants} \
        ${lib.optionalString (sizeVariants != [ ]) "--size " + toString sizeVariants} \
        ${lib.optionalString (tweaks != [ ]) "--tweaks " + toString tweaks} \
        --dest $out/share/themes

      ${lib.optionalString wallpapers "sh -x wallpaper/install-wallpapers.sh"}

      ${lib.optionalString withGrub ''
        (
        cd other/grub2

        patchShebangs install.sh

        ./install.sh --justcopy --dest $out/share/grub/themes \
          ${lib.optionalString (builtins.elem "nord" tweaks) "--theme nord"} \
          ${lib.optionalString (grubScreens != [ ]) "--screen " + toString grubScreens}
        )
      ''}

      jdupes --quiet --link-soft --recurse $out/share

      runHook postInstall
    '';

    propagatedUserEnvPkgs = [
      gtk-engine-murrine
    ];

    passthru.updateScript = gitUpdater { };

    meta = {
      description = "Flat Gtk+ theme based on Elegant Design";
      homepage = "https://github.com/vinceliuice/Graphite-gtk-theme";
      license = lib.licenses.gpl3Only;
      maintainers = [ lib.maintainers.romildo ];
      platforms = lib.platforms.unix;
    };
  }
