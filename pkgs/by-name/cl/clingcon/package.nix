{
  lib,
  stdenv,
  fetchFromGitHub,
  catch2,
  clingo,
  cmake,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "clingcon";
  version = "5.2.1";

  src = fetchFromGitHub {
    owner = "potassco";
    repo = "clingcon";
    tag = "v${finalAttrs.version}";
    sha256 = "sha256-R2kgcw8VUwhOdvPXnsahT5gnoUd5DXLqfdH++8rFoAA=";
  };

  postPatch = ''
    cp ${catch2}/include/catch2/catch.hpp libclingcon/tests/catch.hpp
  '';

  nativeBuildInputs = [
    cmake
    clingo
  ];

  cmakeFlags = [
    "-DCLINGCON_MANAGE_RPATH=ON"
    "-DPYCLINGCON_ENABLE=OFF"
    "-DCLINGCON_BUILD_TESTS=ON"
  ];

  doCheck = true;

  meta = {
    description = "Extension of clingo to handle constraints over integers";
    homepage = "https://potassco.org/";
    changelog = "https://github.com/potassco/clingcon/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
    mainProgram = "clingcon";
    downloadPage = "https://github.com/potassco/clingcon/releases/";
  };
})
