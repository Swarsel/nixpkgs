{
  lib,
  stdenv,
  fetchFromGitHub,
  boost,
  clr,
  cmake,
  half,
  openmp,
  python3Packages,
  rocm-cmake,
  rocm-docs-core,
  rocmUpdateScript,
  buildDocs ? false, # Needs internet
  gpuTargets ? clr.localGpuTargets or [ ],
  useCPU ? false,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "rpp-${if useCPU then "cpu" else "hip"}";
  version = "7.2.3";

  src = fetchFromGitHub {
    owner = "ROCm";
    repo = "rpp";
    rev = "rocm-${finalAttrs.version}";
    hash = "sha256-6e4JHKFC2dvtSGo9xbQKzIdUwlHB09pr5C/5xHwP3l4=";
  };

  postPatch = lib.optionalString (!useCPU) ''
    # Bad path
    substituteInPlace CMakeLists.txt \
      --replace "COMPILER_FOR_HIP \''${ROCM_PATH}/llvm/bin/clang++" "COMPILER_FOR_HIP ${clr}/bin/hipcc"
  '';

  nativeBuildInputs = [
    cmake
    rocm-cmake
    clr
  ]
  ++ lib.optionals buildDocs [
    rocm-docs-core
    python3Packages.python
  ];

  buildInputs = [
    half
    openmp
    boost
  ];

  cmakeFlags = [
    "-DROCM_PATH=${clr}"
    "-DCMAKE_INSTALL_BINDIR=bin"
    "-DCMAKE_INSTALL_LIBDIR=lib"
    "-DCMAKE_INSTALL_INCLUDEDIR=include"
    "-DBACKEND=${if useCPU then "CPU" else "HIP"}"
  ]
  ++ lib.optionals (gpuTargets != [ ]) [
    "-DAMDGPU_TARGETS=${lib.concatStringsSep ";" gpuTargets}"
  ];

  postBuild = lib.optionalString buildDocs ''
    python3 -m sphinx -T -E -b html -d _build/doctrees -D language=en ../docs _build/html
  '';

  passthru.updateScript = rocmUpdateScript { inherit finalAttrs; };

  meta = {
    description = "Comprehensive high-performance computer vision library for AMD processors";
    homepage = "https://github.com/ROCm/rpp";
    license = with lib.licenses; [ mit ];
    platforms = lib.platforms.linux;
    teams = [ lib.teams.rocm ];
  };
})
