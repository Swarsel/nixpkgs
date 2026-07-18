{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  expat,
  # Only required on Linux
  glew,
  imath,
  lcms2,
  libglut,
  minizip-ng,
  openexr,
  pystring,
  python3Packages,
  yaml-cpp,
  zlib,
  # Build apps
  buildApps ? true, # Utility applications
  # Python bindings
  pythonBindings ? true, # Python bindings
}:

stdenv.mkDerivation rec {
  pname = "opencolorio";
  version = "2.5.2";

  src = fetchFromGitHub {
    owner = "AcademySoftwareFoundation";
    repo = "OpenColorIO";
    rev = "v${version}";
    hash = "sha256-b4tdQ9VH9M7hAD5Uuxu4QKwwpaVwroj/Bvg+Zsy0M1M=";
  };

  postPatch = lib.optionalString stdenv.hostPlatform.isDarwin ''
    # these tests don't like being run headless on darwin. no builtin
    # way of skipping tests so this is what we're reduced to.
    substituteInPlace tests/cpu/Config_tests.cpp \
      --replace-fail 'OCIO_ADD_TEST(Config, virtual_display)' 'static void _skip_virtual_display()' \
      --replace-fail 'OCIO_ADD_TEST(Config, virtual_display_with_active_displays)' 'static void _skip_virtual_display_with_active_displays()'

    # can't just use /tmp like that on macos
    substituteInPlace tests/cpu/UnitTestUtils.cpp \
      --replace-fail '"/tmp"' '"'"$(mktemp -d)"'"'
  '';

  nativeBuildInputs = [ cmake ] ++ lib.optionals pythonBindings [ python3Packages.python ];

  buildInputs = [
    expat
    yaml-cpp
    pystring
    imath
    minizip-ng
    zlib
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    glew
    libglut
  ]
  ++ lib.optionals pythonBindings [
    python3Packages.python
    python3Packages.pybind11
  ]
  ++ lib.optionals buildApps [
    lcms2
    openexr
  ];

  cmakeFlags = [
    "-DOCIO_INSTALL_EXT_PACKAGES=NONE"
    "-DOCIO_USE_SSE2NEON=OFF"
    # GPU test fails with: libglut (GPU tests): failed to open display ''
    "-DOCIO_BUILD_GPU_TESTS=OFF"
    "-Dminizip-ng_INCLUDE_DIR=${minizip-ng}/include/minizip-ng"
  ]
  ++ lib.optional (!pythonBindings) "-DOCIO_BUILD_PYTHON=OFF"
  ++ lib.optional (!buildApps) "-DOCIO_BUILD_APPS=OFF";

  # Gcc blindly tries to optimize all float operations instead of just marked ones.
  # https://gcc.gnu.org/bugzilla/show_bug.cgi?id=122304
  env.CXXFLAGS = "-ffp-contract=on";
  # precision issues on non-x86
  doCheck = stdenv.hostPlatform.isx86_64;
  # Tends to fail otherwise.
  enableParallelChecking = false;

  meta = {
    description = "Color management framework for visual effects and animation";
    homepage = "https://opencolorio.org";
    license = lib.licenses.bsd3;
    maintainers = [ lib.maintainers.rytone ];
    platforms = lib.platforms.unix;
  };
}
