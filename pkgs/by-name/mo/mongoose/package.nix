{
  lib,
  stdenv,
  fetchFromGitHub,
  blas,
  cmake,
  llvmPackages,
}:

let
  suitesparseVersion = "7.12.1";
in
stdenv.mkDerivation {
  pname = "mongoose";
  version = "3.3.6";

  src = fetchFromGitHub {
    owner = "DrTimothyAldenDavis";
    repo = "SuiteSparse";
    tag = "v${suitesparseVersion}";
    hash = "sha256-6EMPEH5dcNT1qtuSlzR26RhpfN7MbYJdSKcrsQ0Pzow=";
  };

  outputs = [
    "bin"
    "out"
    "dev"
  ];

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = [
    blas
  ]
  ++ lib.optionals stdenv.cc.isClang [
    llvmPackages.openmp
  ];

  cmakeFlags = [
    "-DCMAKE_BUILD_WITH_INSTALL_NAME_DIR=ON"
  ];

  buildPhase = ''
    runHook preBuild

    for f in SuiteSparse_config Mongoose; do
      (cd $f && cmakeConfigurePhase && make -j$NIX_BUILD_CORES)
    done

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    for f in SuiteSparse_config Mongoose; do
      (cd $f/build && make install -j$NIX_BUILD_CORES)
    done

    runHook postInstall
  '';

  dontUseCmakeConfigure = true;

  meta = {
    description = "Graph Coarsening and Partitioning Library";
    homepage = "https://github.com/DrTimothyAldenDavis/SuiteSparse/tree/dev/Mongoose";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ wegank ];
    platforms = with lib.platforms; unix;
    mainProgram = "suitesparse_mongoose";
  };
}
