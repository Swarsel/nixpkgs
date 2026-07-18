{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  hdf5-threadsafe,
  openexr,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "alembic";
  version = "1.8.8";

  src = fetchFromGitHub {
    owner = "alembic";
    repo = "alembic";
    tag = finalAttrs.version;
    hash = "sha256-R69UYyvLnMwv1JzEQ6S6elvR83Rmvc8acBJwSV/+hCk=";
  };

  # note: out is unused (but required for outputDoc anyway)
  outputs = [
    "bin"
    "dev"
    "out"
    "lib"
  ];

  postPatch = ''
    find bin/ -type f -name CMakeLists.txt -print -exec \
      sed -i 's/INSTALL(TARGETS \([a-zA-Z ]*\) DESTINATION bin)/INSTALL(TARGETS \1)/' {} \;
  '';

  nativeBuildInputs = [ cmake ];

  buildInputs = [
    openexr
    hdf5-threadsafe
  ];

  # These flags along with the postPatch step ensure that all artifacts end up
  # in the correct output without needing to move anything
  #
  # - bin: Uses CMAKE_INSTALL_BINDIR (set via CMake setup hooK)
  # - lib (contains shared libraries): Uses ALEMBIC_LIB_INSTALL_DIR
  # - dev (headers): Uses CMAKE_INSTALL_PREFIX
  #   (this works because every other install rule uses an absolute DESTINATION)
  # - dev (CMake files): Uses ConfigPackageLocation
  cmakeFlags = [
    "-DUSE_HDF5=ON"
    "-DUSE_TESTS=ON"
    "-DALEMBIC_LIB_INSTALL_DIR=${placeholder "lib"}/lib"
    "-DConfigPackageLocation=${placeholder "dev"}/lib/cmake/Alembic"
    "-DCMAKE_INSTALL_PREFIX=${placeholder "dev"}"
    "-DQUIET=ON"
  ];

  doCheck = true;
  enableParallelChecking = false;
  # Prevent cycle between bin and dev (only occurs on Darwin for some reason)
  propagatedBuildOutputs = [ "lib" ];

  meta = {
    description = "Open framework for storing and sharing scene data";
    homepage = "http://alembic.io/";
    license = lib.licenses.bsd3;

    maintainers = with lib.maintainers; [
      guibou
      tmarkus
    ];

    platforms = lib.platforms.all;
  };
})
