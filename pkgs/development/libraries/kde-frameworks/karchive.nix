{
  bzip2,
  cmake,
  extra-cmake-modules,
  mkDerivation,
  qtbase,
  qttools,
  xz,
  zlib,
  zstd,
}:

mkDerivation {
  pname = "karchive";

  outputs = [
    "out"
    "dev"
  ];

  nativeBuildInputs = [
    cmake
    extra-cmake-modules
    qttools
  ];

  buildInputs = [
    bzip2
    xz
    zlib
    zstd
  ];

  propagatedBuildInputs = [ qtbase ];
}
