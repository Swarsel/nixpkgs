{
  lib,
  stdenv,
  fetchurl,
  fetchFromGitLab,
  boost,
  bzip2,
  cmake,
  copyDesktopItems,
  ffmpeg,
  fftwSinglePrec,
  hdf5,
  imagemagick,
  makeDesktopItem,
  muparser,
  netcdf,
  nix-update-script,
  openssl,
  python3,
  qt6Packages,
  wrapGAppsHook3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ovito";
  version = "3.15.5";

  src = fetchFromGitLab {
    owner = "stuko";
    repo = "ovito";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ySU9AW4p7u1/yR9uOSmS82vIwx5fh4pWrFEqBZOoEHA=";
    fetchSubmodules = true;
  };

  postPatch = ''
    substituteInPlace src/ovito/core/CMakeLists.txt \
      --replace-fail " IF(OVITO_BUILD_CONDA)" " IF(TRUE)"
  '';

  nativeBuildInputs = [
    cmake
    qt6Packages.wrapQtAppsHook
    wrapGAppsHook3
    imagemagick
    copyDesktopItems
  ];

  buildInputs = [
    boost
    bzip2
    ffmpeg
    fftwSinglePrec
    hdf5
    muparser
    netcdf
    openssl
    python3
    qt6Packages.qscintilla
    qt6Packages.qtbase
    qt6Packages.qtsvg
    qt6Packages.qttools
    # needed to run natively on wayland
    qt6Packages.qtwayland
  ];

  postInstall =
    let
      icon = fetchurl {
        hash = "sha256-FOmIUeXem+4MjavQNag0UIlcR2wa2emJjivwxoJh6fI=";
        url = "https://www.ovito.org/wp-content/uploads/logo_rgb-768x737.png";
      };
    in
    ''
      mkdir -p $out/share/icons/hicolor/512x512/apps
      magick ${icon} -resize 512x512 $out/share/icons/hicolor/512x512/apps/ovito.png
    '';

  preFixup = ''
    qtWrapperArgs+=("''${gappsWrapperArgs[@]}")
  '';

  # manually create a desktop file
  desktopItems = [
    (makeDesktopItem {
      categories = [ "Science" ];
      comment = "Open Visualization Tool";
      desktopName = "ovito";
      exec = "ovito";
      icon = "ovito";
      name = "ovito";
      startupNotify = false;
      startupWMClass = "Ovito";
      terminal = false;
    })
  ];

  dontWrapGApps = true;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Scientific visualization and analysis software for atomistic and particle simulation data";
    homepage = "https://ovito.org";
    changelog = "https://docs.ovito.org/new_features.html";

    license = with lib.licenses; [
      gpl3Only
      mit
    ];

    maintainers = with lib.maintainers; [
      twhitehead
      chn
      chillcicada
    ];

    mainProgram = "ovito";
    broken = stdenv.hostPlatform.isDarwin; # clang-11: error: no such file or directory: '$-DOVITO_COPYRIGHT_NOTICE=...
  };
})
