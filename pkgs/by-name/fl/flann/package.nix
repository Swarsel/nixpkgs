{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  fetchpatch,
  lz4,
  pkg-config,
  python3,
  unzip,
  enablePython ? false,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "flann";
  version = "1.9.1";

  src = fetchFromGitHub {
    owner = "flann-lib";
    repo = "flann";
    rev = finalAttrs.version;
    sha256 = "13lg9nazj5s9a41j61vbijy04v6839i67lqd925xmxsbybf36gjc";
  };

  patches = [
    # Patch HDF5_INCLUDE_DIR -> HDF_INCLUDE_DIRS.
    (fetchpatch {
      sha256 = "yM1ONU4mu6lctttM5YcSTg8F344TNUJXwjxXLqzr5Pk=";
      url = "https://salsa.debian.org/science-team/flann/-/raw/debian/1.9.1+dfsg-9/debian/patches/0001-Updated-fix-cmake-hdf5.patch";
    })
    # Patch no-source library workaround that breaks on CMake > 3.11.
    (fetchpatch {
      sha256 = "REsBnbe6vlrZ+iCcw43kR5wy2o6q10RM73xjW5kBsr4=";
      url = "https://salsa.debian.org/science-team/flann/-/raw/debian/1.9.1+dfsg-9/debian/patches/0001-src-cpp-fix-cmake-3.11-build.patch";
    })
  ]
  ++ lib.optionals (!stdenv.cc.isClang) [
    # Avoid the bundled version of LZ4 and instead use the system one.
    (fetchpatch {
      sha256 = "xi+GyFn9PEjLgbJeAIEmsbp7ut9G9KIBkVulyT3nfsg=";
      url = "https://salsa.debian.org/science-team/flann/-/raw/debian/1.9.1+dfsg-9/debian/patches/0003-Use-system-version-of-liblz4.patch";
    })
    # Fix LZ4 string separator issue, see: https://github.com/flann-lib/flann/pull/480
    (fetchpatch {
      sha256 = "qt8h576Gn8uR7+T9u9bEBIRz6e6AoTKpa1JfdZVvW9s=";
      url = "https://github.com/flann-lib/flann/commit/25eb56ec78472bd419a121c6905095a793cf8992.patch";
    })
  ]
  ++ lib.optionals stdenv.cc.isClang [
    # Fix build with Clang 16.
    (fetchpatch {
      hash = "sha256-4SUKzQCm0Sx8N43Z6ShuMbgbbe7q8b2Ibk3WgkB0qa4=";
      url = "https://github.com/flann-lib/flann/commit/be80cefa69b314a3d9e1ab971715e84145863ebb.patch";
    })
  ];

  # The LZ4 patch updates cmake_minimum_required to 3.12, but only for non-clang builds.
  # For clang builds (like Darwin), we need to manually update it.
  # ref. https://github.com/flann-lib/flann/pull/526 not merged yet
  postPatch = lib.optionalString stdenv.cc.isClang ''
    substituteInPlace CMakeLists.txt \
      --replace-fail "cmake_minimum_required(VERSION 2.6)" "cmake_minimum_required(VERSION 3.5)"
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
    unzip
  ];

  buildInputs = lib.optionals enablePython [ python3 ];
  # lz4 unbundling broken for llvm, use internal version
  propagatedBuildInputs = lib.optional (!stdenv.cc.isClang) lz4;

  cmakeFlags = [
    "-DBUILD_EXAMPLES:BOOL=OFF"
    "-DBUILD_TESTS:BOOL=OFF"
    "-DBUILD_MATLAB_BINDINGS:BOOL=OFF"
    "-DBUILD_PYTHON_BINDINGS:BOOL=${if enablePython then "ON" else "OFF"}"
  ];

  meta = {
    description = "Fast approximate nearest neighbor searches in high dimensional spaces";
    homepage = "https://github.com/flann-lib/flann";
    license = lib.licenses.bsd3;
    maintainers = [ ];
    platforms = with lib.platforms; linux ++ darwin;
  };
})
