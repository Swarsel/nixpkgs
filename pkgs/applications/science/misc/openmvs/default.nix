{
  lib,
  stdenv,
  fetchFromGitHub,
  boost,
  ceres-solver,
  cgal,
  cmake,
  eigen,
  glfw,
  gmp,
  libjpeg,
  libjxl,
  libpng,
  libtiff,
  mpfr,
  nanoflann,
  opencv,
  openmp,
  pkg-config,
  python3Packages,
  vcg,
  zstd,
}:

let
  boostWithZstd = boost.overrideAttrs (old: {
    buildInputs = old.buildInputs ++ [ zstd ];
  });
in
stdenv.mkDerivation rec {
  pname = "openmvs";
  version = "2.4.0";

  src = fetchFromGitHub {
    owner = "cdcseacave";
    repo = "openmvs";
    rev = "v${version}";
    hash = "sha256-0tL2tqHYBQMGL9k+NqTUxieWuDP3YB6X9DcXYnlGWWg=";
    fetchSubmodules = true;
  };

  postPatch = ''
    substituteInPlace CMakeLists.txt --replace-fail \
      'FIND_PACKAGE(Boost REQUIRED COMPONENTS iostreams program_options system serialization OPTIONAL_COMPONENTS ''${Boost_EXTRA_COMPONENTS})' \
      'FIND_PACKAGE(Boost REQUIRED COMPONENTS iostreams program_options serialization OPTIONAL_COMPONENTS ''${Boost_EXTRA_COMPONENTS})'
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
    python3Packages.python
  ];

  buildInputs = [
    boostWithZstd
    ceres-solver
    cgal
    eigen
    glfw
    gmp
    libjxl
    libjpeg
    libpng
    libtiff
    mpfr
    nanoflann
    opencv
    openmp
    vcg
  ];

  # SSE is enabled by default
  cmakeFlags = [
    (lib.cmakeFeature "Python3_EXECUTABLE" (lib.getExe python3Packages.python))
  ]
  ++ lib.optional (!stdenv.hostPlatform.isx86_64) "-DOpenMVS_USE_SSE=OFF";

  doCheck = true;

  checkPhase = ''
    runHook preCheck
    ${lib.optionalString (stdenv.hostPlatform.isLinux && stdenv.hostPlatform.isAarch64) ''
      export KMP_AFFINITY=disabled
      export OMP_PROC_BIND=false
    ''}
    ctest --output-on-failure
    runHook postCheck
  '';

  postInstall = ''
    mv $out/bin/OpenMVS/* $out/bin
    rmdir $out/bin/OpenMVS
    rm $out/bin/Tests
  '';

  meta = {
    description = "Open Multi-View Stereo reconstruction library";
    homepage = "https://github.com/cdcseacave/openMVS";
    license = lib.licenses.agpl3Only;

    maintainers = with lib.maintainers; [
      bouk
      miniharinn
    ];

    platforms = lib.platforms.unix;
  };
}
