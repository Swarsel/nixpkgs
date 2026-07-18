{
  lib,
  fetchFromGitHub,
  blas,
  boost,
  catch2,
  clangStdenv,
  cmake,
  eigen,
  fetchpatch,
  fmt,
  gsl,
  liblapack,
  lua,
  luaPackages,
  rang,
  yaml-cpp,
}:

clangStdenv.mkDerivation rec {
  pname = "d-SEAMS";
  version = "1.0.1";

  src = fetchFromGitHub {
    owner = "d-SEAMS";
    repo = "seams-core";
    rev = "v${version}";
    sha256 = "03zhhl9vhi3rhc3qz1g3zb89jksgpdlrk15fcr8xcz8pkj6r5b1i";
  };

  patches = [
    (fetchpatch {
      hash = "sha256-PLbT1lqdw+69lIHH96MPcGRjfIeZyb88vc875QLYyqw=";
      name = "use_newer_cxxopts_which_builds_with_clang11.patch";
      url = "https://github.com/d-SEAMS/seams-core/commit/f6156057e43d0aa1a0df9de67d8859da9c30302d.patch";
    })
    # Add missing <cstdint> include for uint8_t in vendored cxxopts.
    ./cxxopts-cstdint.patch
  ];

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace-fail "cmake_minimum_required(VERSION 3.0 FATAL_ERROR)" "cmake_minimum_required(VERSION 3.10)"
  '';

  strictDeps = false;

  nativeBuildInputs = [
    cmake
    lua
    luaPackages.luafilesystem
  ];

  buildInputs = [
    fmt
    rang
    yaml-cpp
    eigen
    catch2
    boost
    gsl
    liblapack
    blas
  ];

  meta = {
    description = "Deferred Structural Elucidation Analysis for Molecular Simulations";

    longDescription = ''
      d-SEAMS, is a free and open-source postprocessing engine for the analysis
      of molecular dynamics trajectories, which is specifically able to
      qualitatively classify ice structures in both strong-confinement and bulk
      systems. The engine is in C++, with extensions via the Lua scripting
      interface.
    '';

    homepage = "https://dseams.info";
    license = lib.licenses.gpl3Plus;
    maintainers = [ ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "yodaStruct";
  };
}
