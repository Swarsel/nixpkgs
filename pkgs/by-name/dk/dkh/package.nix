{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  gfortran,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "dkh";
  version = "1.2";

  src = fetchFromGitHub {
    owner = "psi4";
    repo = "dkh";
    rev = "v${finalAttrs.version}";
    sha256 = "1wb4qmb9f8rnrwnnw1gdhzx1fmhy628bxfrg56khxy3j5ljxkhck";
  };

  postPatch = ''
    substituteInPlace CMakeLists.txt \
    --replace-fail "cmake_minimum_required(VERSION 3.0)"  "cmake_minimum_required(VERSION 3.10)"
  '';

  nativeBuildInputs = [
    gfortran
    cmake
  ];

  cmakeFlags = [ "-DBUILD_SHARED_LIBS=ON" ];

  hardeningDisable = [
    "format"
  ];

  meta = {
    description = "Arbitrary-order scalar-relativistic Douglas-Kroll-Hess module";
    homepage = "https://github.com/psi4/dkh";
    license = lib.licenses.lgpl3Only;
    maintainers = [ lib.maintainers.sheepforce ];
    platforms = lib.platforms.unix;
  };
})
