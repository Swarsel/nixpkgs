{
  lib,
  stdenv,
  buildLlvmPackages,
  clang,
  cmake,
  libclang,
  libffi,
  libllvm,
  libxml2,
  llvm_meta,
  mlir,
  monorepoSrc,
  ninja,
  python3,
  release_version,
  runCommand,
  version,
  devExtraCmakeFlags ? [ ],
}:

stdenv.mkDerivation (finalAttrs: {
  inherit version;
  pname = "flang";

  src =
    runCommand "${finalAttrs.pname}-src-${finalAttrs.version}"
      {
        inherit (monorepoSrc) passthru;
      }
      ''
        mkdir -p "$out"
        cp -r ${monorepoSrc}/${finalAttrs.pname} "$out"
        cp -r ${monorepoSrc}/cmake "$out"
        cp -r ${monorepoSrc}/llvm "$out"
        cp -r ${monorepoSrc}/clang "$out"
        cp -r ${monorepoSrc}/mlir "$out"
        cp -r ${monorepoSrc}/third-party "$out"
        cp -r ${monorepoSrc}/flang-rt "$out"
        chmod -R +w $out/llvm
      '';

  outputs = [ "out" ];
  patches = [ ];

  nativeBuildInputs = [
    cmake
    clang
    ninja
    python3
    libllvm.dev
    mlir.dev
  ];

  buildInputs = [
    libffi
    libxml2
    libllvm
    libclang
    mlir
  ];

  cmakeFlags = [
    (lib.cmakeFeature "LLVM_DIR" "${libllvm.dev}/lib/cmake/llvm")
    (lib.cmakeFeature "LLVM_TOOLS_BINARY_DIR" "${buildLlvmPackages.tblgen}/bin/")
    (lib.cmakeFeature "CLANG_DIR" "${libclang.dev}/lib/cmake/clang")
    (lib.cmakeFeature "MLIR_DIR" "${mlir.dev}/lib/cmake/mlir")
    (lib.cmakeFeature "MLIR_TABLEGEN_EXE" "${buildLlvmPackages.tblgen}/bin/mlir-tblgen")
    (lib.cmakeBool "MLIR_LINK_MLIR_DYLIB" (!stdenv.hostPlatform.isStatic))
    (lib.cmakeFeature "LLVM_LIT_ARGS" "-v")
    (lib.cmakeBool "LLVM_ENABLE_PLUGINS" false)
    (lib.cmakeBool "FLANG_STANDALONE_BUILD" true)
    (lib.cmakeBool "LLVM_INCLUDE_EXAMPLES" false)
    (lib.cmakeBool "FLANG_INCLUDE_TESTS" false)
  ]
  ++ devExtraCmakeFlags;

  preConfigure = ''
    ls -l ${libllvm.dev}/lib/cmake/llvm/LLVMConfig.cmake
    ls -l ${libclang.dev}/lib/cmake/clang/ClangConfig.cmake
    ls -l ${mlir.dev}/lib/cmake/mlir/MLIRConfig.cmake
  '';

  patchFlags = [ "-p1" ];

  postUnpack = ''
    chmod -R u+w -- $sourceRoot/..
  '';

  requiredSystemFeatures = [ "big-parallel" ];
  sourceRoot = "${finalAttrs.src.name}/flang";

  passthru = {
    hardeningUnsupportedFlags = [
      "zerocallusedregs"
      "stackprotector"
      "stackclashprotection"
    ];

    isClang = true;
    isFlang = true;
    # Used by cc-wrapper to determine whether or not the default setup hook is enabled.
    langC = false;
    langCC = false;
    langFortran = true;
  };

  meta = llvm_meta // {
    description = "LLVM-based Fortran frontend";
    homepage = "https://flang.llvm.org/";
    license = lib.licenses.ncsa;
    maintainers = with lib.maintainers; [ acture ];
    mainProgram = "flang";
  };
})
