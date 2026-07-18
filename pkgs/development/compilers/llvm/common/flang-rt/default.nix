{
  lib,
  stdenv,
  buildFlang,
  cmake,
  libllvm,
  llvm_meta,
  monorepoSrc,
  ninja,
  python3,
  runCommand,
  version,
}:
let

  minDarwinVersion = "10.12";
  effectiveDarwinVersion =
    if stdenv.isDarwin && lib.versionOlder stdenv.hostPlatform.darwinMinVersion minDarwinVersion then
      minDarwinVersion
    else
      stdenv.hostPlatform.darwinMinVersion;
in
stdenv.mkDerivation (finalAttrs: {
  inherit version;
  pname = "flang-rt";

  src =
    runCommand "${finalAttrs.pname}-src-${version}"
      {
        inherit (monorepoSrc) passthru;
      }
      ''
        mkdir -p "$out"
        cp -r ${monorepoSrc}/cmake "$out"

        mkdir -p "$out/llvm"
        cp -r ${monorepoSrc}/llvm/cmake "$out/llvm"
        cp -r ${monorepoSrc}/llvm/utils "$out/llvm"
        cp -r ${monorepoSrc}/third-party "$out"

        cp -r ${monorepoSrc}/${finalAttrs.pname} "$out"
        cp -r ${monorepoSrc}/flang "$out"
        cp -r ${monorepoSrc}/runtimes "$out"
      '';

  outputs = [ "out" ];

  nativeBuildInputs = [
    buildFlang
    cmake
    ninja
    python3
  ];

  buildInputs = [
    libllvm
  ];

  cmakeFlags = [
    (lib.cmakeFeature "LLVM_DEFAULT_TARGET_TRIPLE" stdenv.hostPlatform.config)
    (lib.cmakeFeature "CMAKE_Fortran_COMPILER" "${buildFlang}/bin/flang")
    (lib.cmakeBool "CMAKE_Fortran_COMPILER_WORKS" true)
    (lib.cmakeBool "CMAKE_Fortran_COMPILER_SUPPORTS_F90" true)
    (lib.cmakeFeature "LLVM_DIR" "${libllvm.dev}/lib/cmake/llvm")
    (lib.cmakeFeature "LLVM_ENABLE_RUNTIMES" "flang-rt")
  ]
  ++ lib.optionals stdenv.isDarwin [
    (lib.cmakeFeature "CMAKE_OSX_DEPLOYMENT_TARGET" effectiveDarwinVersion)
  ];

  env = lib.optionalAttrs stdenv.isDarwin {
    MACOSX_DEPLOYMENT_TARGET = effectiveDarwinVersion;
    NIX_CFLAGS_COMPILE = "-mmacosx-version-min=${effectiveDarwinVersion}";
  };

  sourceRoot = "${finalAttrs.src.name}/runtimes";

  meta = llvm_meta // {
    description = "LLVM Fortran Runtime";
    homepage = "https://flang.llvm.org";
  };
})
