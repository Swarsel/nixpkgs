{
  lib,
  stdenv,
  fetchFromGitHub,
  boost,
  buildPackages,
  cairo,
  catch2,
  cmake,
  freetype,
  gdal,
  gitUpdater,
  harfbuzz,
  icu,
  libavif,
  libjpeg,
  libpng,
  libpq,
  libtiff,
  libwebp,
  libxml2,
  openssl,
  pkg-config,
  proj,
  protozero,
  python3,
  sparsehash,
  sqlite,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "mapnik";
  version = "4.2.2";

  src = fetchFromGitHub {
    owner = "mapnik";
    repo = "mapnik";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Cx6RO22A4JKLlSeKBgXwSCpwh4P4B6i+jKaDa21PJXI=";
    fetchSubmodules = true;
  };

  # a distinct dev output makes python-mapnik fail
  outputs = [ "out" ];

  patches = [
    # Account for full paths when generating libmapnik.pc
    ./export-pkg-config-full-paths.patch
    # Use 'sparsehash' package.
    ./use-sparsehash-package.patch
  ];

  postPatch = ''
    substituteInPlace configure \
      --replace-fail '$PYTHON scons/scons.py' ${buildPackages.scons}/bin/scons
    rm -r scons
    # Remove bundled 'sparsehash' directory in favor of 'sparsehash' package
    rm -r deps/mapnik/sparsehash
    # Remove bundled 'protozero' directory in favor of 'protozero' package
    rm -r deps/mapbox/protozero
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    boost
    cairo
    freetype
    gdal
    (harfbuzz.override { withIcu = true; })
    icu
    libavif
    libjpeg
    libpng
    libtiff
    libwebp
    proj
    python3
    sqlite
    zlib
    libxml2
    libpq
    protozero
    sparsehash
    openssl
  ];

  cmakeFlags = [
    # Save time by not building some development-related code.
    (lib.cmakeBool "BUILD_BENCHMARK" false)
    (lib.cmakeBool "BUILD_DEMO_CPP" false)
    ## Would require QT otherwise.
    (lib.cmakeBool "BUILD_DEMO_VIEWER" false)
    # disable the find_package call and force pkg-config, see https://github.com/mapnik/mapnik/pull/4270
    (lib.cmakeBool "CMAKE_DISABLE_FIND_PACKAGE_harfbuzz" true)
    # Use 'protozero' package.
    (lib.cmakeBool "USE_EXTERNAL_MAPBOX_PROTOZERO" true)
    # macOS builds fail when using memory mapped file cache.
    (lib.cmakeBool "USE_MEMORY_MAPPED_FILE" (!stdenv.hostPlatform.isDarwin))
    # don't try to download sources for catch2, use our own
    (lib.cmakeFeature "FETCHCONTENT_SOURCE_DIR_CATCH2" "${catch2.src}")
  ];

  # mapnik-config is currently not build with CMake. So we use the SCons for
  # this one. We can't add SCons to nativeBuildInputs though, as stdenv would
  # then try to build everything with scons. C++17 is the minimum supported
  # C++ version.
  preBuild = ''
    cd ..
    env CXX_STD=17 ${buildPackages.scons}/bin/scons utils/mapnik-config
    cd build
  '';

  doCheck = true;

  preInstall = ''
    install -Dm755 ../utils/mapnik-config/mapnik-config -t $out/bin
  '';

  passthru.updateScript = gitUpdater { rev-prefix = "v"; };

  meta = {
    description = "Open source toolkit for developing mapping applications";
    homepage = "https://mapnik.org";
    changelog = "https://github.com/mapnik/mapnik/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.lgpl21Plus;

    maintainers = with lib.maintainers; [
      hummeltech
    ];

    platforms = lib.platforms.all;
    teams = [ lib.teams.geospatial ];
  };
})
