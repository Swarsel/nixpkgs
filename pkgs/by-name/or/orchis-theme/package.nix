{
  lib,
  fetchFromGitHub,
  gnome-themes-extra,
  gtk-engine-murrine,
  gtk3,
  sassc,
  stdenvNoCC,
  border-radius ? null, # Suggested: 2 < value < 16
  tweaks ? [ ], # can be "solid" "compact" "black" "primary" "macos" "submenu" "nord|dracula"
  withWallpapers ? false,
}:

let
  pname = "orchis-theme";

  validTweaks = [
    "solid"
    "compact"
    "black"
    "primary"
    "macos"
    "submenu"
    "nord"
    "dracula"
  ];

  nordXorDracula =
    with builtins;
    lib.assertMsg (!(elem "nord" tweaks) || !(elem "dracula" tweaks)) ''
      ${pname}: dracula and nord cannot be mixed. Tweaks ${toString tweaks}
    '';
in

assert nordXorDracula;
lib.checkListOfEnum "${pname}: theme tweaks" validTweaks tweaks

  stdenvNoCC.mkDerivation
  rec {
    inherit pname;
    version = "2025-04-25";

    src = fetchFromGitHub {
      owner = "vinceliuice";
      repo = "Orchis-theme";
      rev = version;
      hash = "sha256-+2/CsgJ+rdDpCp+r5B/zys3PtFgtnu+ohTEUOtJNd1Y=";
    };

    nativeBuildInputs = [
      gtk3
      sassc
    ];

    buildInputs = [ gnome-themes-extra ];

    preInstall = ''
      mkdir -p $out/share/themes
    '';

    installPhase = ''
      runHook preInstall
      bash install.sh -d $out/share/themes -t all \
        ${lib.optionalString (tweaks != [ ]) "--tweaks " + toString tweaks} \
        ${lib.optionalString (border-radius != null) ("--round " + toString border-radius + "px")}
      ${lib.optionalString withWallpapers ''
        mkdir -p $out/share/backgrounds
        cp src/wallpaper/{1080p,2k,4k}.jpg $out/share/backgrounds
      ''}
      runHook postInstall
    '';

    propagatedUserEnvPkgs = [ gtk-engine-murrine ];

    meta = {
      description = "Material Design theme for GNOME/GTK based desktop environments";
      homepage = "https://github.com/vinceliuice/Orchis-theme";
      license = lib.licenses.gpl3Plus;
      maintainers = [ lib.maintainers.fufexan ];
      platforms = lib.platforms.linux;
    };
  }
