{
  lib,
  stdenv,
  fetchFromGitHub,
  cimg,
  cmake,
  curl,
  fftw,
  gimp,
  gimpPlugins,
  gmic,
  graphicsmagick,
  libjpeg,
  libpng,
  libsForQt5,
  libtiff,
  llvmPackages,
  ninja,
  nix-update-script,
  openexr,
  pkg-config,
  zlib,
  variant ? "standalone",
}:

let
  variants = {
    gimp = {
      description = "GIMP plugin for the G'MIC image processing framework";

      extraDeps = [
        gimp
        gimp.gtk
      ];
    };

    standalone = {
      description = "Versatile front-end to the image processing framework G'MIC";
      extraDeps = [ ]; # Just to keep uniformity and avoid test-for-null
    };
  };

in

assert lib.assertMsg (builtins.hasAttr variant variants)
  "gmic-qt variant \"${variant}\" is not supported. Please use one of ${lib.concatStringsSep ", " (builtins.attrNames variants)}.";

assert lib.assertMsg (builtins.all (d: d != null)
  variants.${variant}.extraDeps
) "gmic-qt variant \"${variant}\" is missing one of its dependencies.";

stdenv.mkDerivation (finalAttrs: {
  pname = "gmic-qt${lib.optionalString (variant != "standalone") "-${variant}"}";
  version = "3.5.0";

  src = fetchFromGitHub {
    owner = "GreycLab";
    repo = "gmic-qt";
    rev = "v.${finalAttrs.version}";
    hash = "sha256-1fav1O75HBC7ySBgybn4goLFkX6HFbwRHARncfbkaoM=";
  };

  postPatch = ''
    patchShebangs \
      translations/filters/csv2ts.sh \
      translations/lrelease.sh

    mkdir ../src
    ln -s ${gmic.src}/src/gmic.cpp ../src/gmic.cpp
  '';

  nativeBuildInputs = [
    cmake
    libsForQt5.wrapQtAppsHook
    ninja
    pkg-config
  ];

  buildInputs = [
    cimg
    curl
    fftw
    gmic
    graphicsmagick
    libjpeg
    libpng
    libtiff
    openexr
    zlib
  ]
  ++ (with libsForQt5; [
    qtbase
    qttools
  ])
  ++ lib.optionals stdenv.cc.isClang [
    llvmPackages.openmp
  ]
  ++ variants.${variant}.extraDeps;

  cmakeFlags = [
    (lib.cmakeBool "ENABLE_DYNAMIC_LINKING" true)
    (lib.cmakeBool "ENABLE_SYSTEM_GMIC" true)
    (lib.cmakeFeature "GMIC_QT_HOST" (
      if variant == "standalone" then
        "none"
      else if variant == "gimp" && gimp.apiVersion == "3.0" then
        "gimp3"
      else
        variant
    ))
  ];

  postFixup = lib.optionalString (variant == "gimp") ''
    echo "wrapping $out/${gimp.targetPluginDir}/gmic_gimp_qt/gmic_gimp_qt"
    wrapQtApp "$out/${gimp.targetPluginDir}/gmic_gimp_qt/gmic_gimp_qt"
  '';

  passthru = {
    tests = {
      inherit cimg gmic;
      # They need to be update in lockstep.
      gimp-plugin = gimpPlugins.gmic;
    };

    updateScript = nix-update-script {
      extraArgs = [
        "--version-regex"
        "^v\\.(.*)"
      ];
    };
  };

  meta = {
    inherit (variants.${variant}) description;
    homepage = "http://gmic.eu/";
    license = lib.licenses.gpl3Plus;
    maintainers = [ ];
    platforms = lib.platforms.unix;
    mainProgram = "gmic_qt";
  };
})
