{
  lib,
  stdenv,
  fetchurl,
  # nativeBuildInputs
  cmake,
  config,
  # cuda-specific
  cudaPackages,
  # buildInputs
  curl,
  # darwin-specific
  desktopToDarwinBundle,
  dos2unix,
  fftw,
  gdal,
  giflib,
  hdf5,
  libharu,
  libiodbc,
  libpq,
  libsForQt5,
  libsvm,
  # darwin-specific
  netcdf,
  opencv,
  pdal,
  pkg-config,
  poppler,
  proj,
  qhull,
  sqlite,
  unixodbc,
  vigra,
  wrapGAppsHook3,
  wxwidgets_3_2,
  xz,
  cudaSupport ? config.cudaSupport,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "saga";
  version = "9.12.6";

  src = fetchurl {
    url = "mirror://sourceforge/saga-gis/saga-${finalAttrs.version}.tar.gz";
    hash = "sha256-1A8Irbl135Uh+ywU4xQrmrp5Byr7UJRfBhvbcc70CIY=";
  };

  postPatch = ''
    dos2unix src/saga_core/saga_gui/res/org.saga_gis.saga_gui.desktop
  '';

  nativeBuildInputs = [
    cmake
    dos2unix
    pkg-config
    wrapGAppsHook3
  ]
  ++ lib.optionals cudaSupport [
    cudaPackages.cuda_nvcc
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    desktopToDarwinBundle
  ];

  buildInputs = [
    curl
    fftw
    gdal
    giflib
    hdf5
    libharu
    libiodbc
    libpq
    libsForQt5.dxflib
    libsvm
    opencv
    pdal
    proj
    qhull
    vigra
    wxwidgets_3_2
    xz
  ]
  ++ lib.optionals cudaSupport [
    cudaPackages.cuda_cudart
  ]
  # See https://groups.google.com/forum/#!topic/nix-devel/h_vSzEJAPXs
  # for why the have additional buildInputs on darwin
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    netcdf
    poppler
    sqlite
    unixodbc
  ];

  cmakeFlags = [
    (lib.cmakeBool "OpenMP_SUPPORT" (!stdenv.hostPlatform.isDarwin))
  ];

  sourceRoot = "saga-${finalAttrs.version}/saga-gis";

  meta = {
    description = "System for Automated Geoscientific Analyses";
    homepage = "https://saga-gis.sourceforge.io";
    changelog = "https://sourceforge.net/p/saga-gis/wiki/Changelog%20${finalAttrs.version}/";
    license = lib.licenses.gpl2Plus;

    maintainers = with lib.maintainers; [
      mpickering
    ];

    platforms = with lib.platforms; unix;
    teams = [ lib.teams.geospatial ];
  };
})
