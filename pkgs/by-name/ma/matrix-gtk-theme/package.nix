{
  lib,
  fetchFromGitHub,
  gnome-shell,
  gnome-themes-extra,
  gtk-engine-murrine,
  sassc,
  stdenvNoCC,
  unstableGitUpdater,
  colorVariants ? [ ],
  iconVariants ? [ ],
  sizeVariants ? [ ],
  themeVariants ? [ ],
  tweakVariants ? [ ],
}:

let
  pname = "matrix-gtk-theme";
  colorVariantList = [
    "dark"
    "light"
  ];
  sizeVariantList = [
    "compact"
    "standard"
  ];
  themeVariantList = [
    "default"
    "green"
    "grey"
    "orange"
    "pink"
    "purple"
    "red"
    "teal"
    "yellow"
    "all"
  ];
  tweakVariantList = [
    "neo"
    "trinity"
    "black"
    "float"
    "outline"
    "macos"
  ];
  iconVariantList = [
    "Dark"
    "Light"
    "Sweet"
  ];
in
lib.checkListOfEnum "${pname}: colorVariants" colorVariantList colorVariants lib.checkListOfEnum
  "${pname}: sizeVariants"
  sizeVariantList
  sizeVariants
  lib.checkListOfEnum
  "${pname}: themeVariants"
  themeVariantList
  themeVariants
  lib.checkListOfEnum
  "${pname}: tweakVariants"
  tweakVariantList
  tweakVariants
  lib.checkListOfEnum
  "${pname}: iconVariants"
  iconVariantList
  iconVariants

  stdenvNoCC.mkDerivation
  {
    inherit pname;
    version = "0-unstable-2025-10-15";

    src = fetchFromGitHub {
      owner = "D3vil0p3r";
      repo = "Matrix-GTK-Theme";
      rev = "d76d8c69cb1fca0f050009ee5893c65954f3ddfe";
      hash = "sha256-RJKHSBj33QR9ahkMd2HwG7FCUB8gtfTzIp0174TPHPE=";
    };

    postPatch = ''
      patchShebangs themes/install.sh
    '';

    nativeBuildInputs = [
      gnome-shell
      sassc
    ];

    buildInputs = [ gnome-themes-extra ];

    installPhase = ''
      runHook preInstall
      mkdir -p $out/share/themes
      cd themes
      ./install.sh -n Matrix \
      ${lib.optionalString (colorVariants != [ ]) "-c " + toString colorVariants} \
      ${lib.optionalString (sizeVariants != [ ]) "-s " + toString sizeVariants} \
      ${lib.optionalString (themeVariants != [ ]) "-t " + toString themeVariants} \
      ${lib.optionalString (tweakVariants != [ ]) "--tweaks " + toString tweakVariants} \
      -d "$out/share/themes"
      cd ../icons
      ${lib.optionalString (iconVariants != [ ]) ''
        mkdir -p $out/share/icons
        cp -a ${toString (map (v: "Matrix-${v}") iconVariants)} $out/share/icons/
      ''}
      runHook postInstall
    '';

    dontBuild = true;
    propagatedUserEnvPkgs = [ gtk-engine-murrine ];
    passthru.updateScript = unstableGitUpdater { };

    meta = {
      description = "GTK theme based on the Matrix colour palette";
      homepage = "https://github.com/D3vil0p3r/Matrix-GTK-Theme";
      license = lib.licenses.gpl3Plus;
      maintainers = [ ];
      platforms = lib.platforms.unix;
    };
  }
