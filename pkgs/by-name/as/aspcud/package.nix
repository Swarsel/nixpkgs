{
  lib,
  stdenv,
  fetchFromGitHub,
  boost,
  catch2,
  clingo,
  cmake,
  fetchpatch,
  re2c,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "aspcud";
  version = "1.9.6";

  src = fetchFromGitHub {
    owner = "potassco";
    repo = "aspcud";
    rev = "v${finalAttrs.version}";
    hash = "sha256-PdRfpmH7zF5dn+feoijtzdSUjaYhjHwyAUfuYoWCL9E=";
  };

  patches = [
    # Bump minimal version of cmake to 3.10
    (fetchpatch {
      excludes = [ "cmake/FindRE2C.cmake" ];
      hash = "sha256-JDNpXLb3ow4JnsZrQ8HqGrRpf/6H/ozJca52pIRVo2w=";
      url = "https://github.com/potassco/aspcud/commit/d88c1aad6f9c1c0081aa1a0eea94ecc7d4ebf855.patch?full_index=1";
    })
  ];

  postPatch = ''
    cp ${catch2}/include/catch2/catch.hpp libcudf/tests/catch.hpp
  '';

  nativeBuildInputs = [ cmake ];

  buildInputs = [
    boost
    clingo
    re2c
  ];

  cmakeFlags = [
    "-DASPCUD_GRINGO_PATH=${clingo}/bin/gringo"
    "-DASPCUD_CLASP_PATH=${clingo}/bin/clasp"
  ];

  doCheck = true;

  meta = {
    description = "Solver for package problems in CUDF format using ASP";
    homepage = "https://potassco.org/aspcud/";
    license = lib.licenses.gpl3Plus;
    maintainers = [ lib.maintainers.hakuch ];
    platforms = lib.platforms.all;
  };
})
