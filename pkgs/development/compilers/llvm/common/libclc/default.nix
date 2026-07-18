{
  lib,
  stdenv,
  buildLlvmPackages,
  buildPackages,
  cmake,
  getVersionFile,
  llvm,
  monorepoSrc,
  ninja,
  python3,
  release_version,
  runCommand,
  version,
}:
let
  spirv-llvm-translator = buildPackages.spirv-llvm-translator.override {
    inherit (buildLlvmPackages) llvm;
  };

  # The build requires an unwrapped clang but wrapped clang++ thus we need to
  # split the unwrapped clang out to prevent the build from finding the
  # unwrapped clang++
  clang-only = runCommand "clang-only" { } ''
    mkdir -p "$out"/bin
    ln -s "${lib.getExe' buildLlvmPackages.clang.cc "clang"}" "$out"/bin
  '';
in
stdenv.mkDerivation (finalAttrs: {
  inherit version;
  pname = "libclc";

  src = runCommand "libclc-src-${version}" { inherit (monorepoSrc) passthru; } ''
    mkdir -p "$out"
    cp -r ${monorepoSrc}/cmake "$out"
    cp -r ${monorepoSrc}/libclc "$out"
  '';

  outputs = [
    "out"
    "dev"
  ];

  patches = [
    (getVersionFile "libclc/gnu-install-dirs.patch")
  ]
  # LLVM 19 changes how host tools are looked up.
  # Need to remove NO_DEFAULT_PATH and the PATHS arguments for find_program
  # so CMake can actually find the tools in nativeBuildInputs.
  # https://github.com/llvm/llvm-project/pull/105969
  ++ lib.optional (lib.versionAtLeast release_version "19") (
    getVersionFile "libclc/use-default-paths.patch"
  );

  # cmake expects all required binaries to be in the same place, so it will not be able to find clang without the patch
  postPatch =
    lib.optionalString (lib.versionOlder release_version "19") ''
      substituteInPlace CMakeLists.txt \
        --replace-fail 'find_program( LLVM_CLANG clang PATHS ''${LLVM_TOOLS_BINARY_DIR} NO_DEFAULT_PATH )' \
                  'find_program( LLVM_CLANG clang PATHS "${buildLlvmPackages.clang.cc}/bin" NO_DEFAULT_PATH )' \
        --replace-fail 'find_program( LLVM_AS llvm-as PATHS ''${LLVM_TOOLS_BINARY_DIR} NO_DEFAULT_PATH )' \
                  'find_program( LLVM_AS llvm-as PATHS "${buildLlvmPackages.llvm}/bin" NO_DEFAULT_PATH )' \
        --replace-fail 'find_program( LLVM_LINK llvm-link PATHS ''${LLVM_TOOLS_BINARY_DIR} NO_DEFAULT_PATH )' \
                  'find_program( LLVM_LINK llvm-link PATHS "${buildLlvmPackages.llvm}/bin" NO_DEFAULT_PATH )' \
        --replace-fail 'find_program( LLVM_OPT opt PATHS ''${LLVM_TOOLS_BINARY_DIR} NO_DEFAULT_PATH )' \
                  'find_program( LLVM_OPT opt PATHS "${buildLlvmPackages.llvm}/bin" NO_DEFAULT_PATH )' \
        --replace-fail 'find_program( LLVM_SPIRV llvm-spirv PATHS ''${LLVM_TOOLS_BINARY_DIR} NO_DEFAULT_PATH )' \
                  'find_program( LLVM_SPIRV llvm-spirv PATHS "${spirv-llvm-translator}/bin" NO_DEFAULT_PATH )'
    ''
    + lib.optionalString (!stdenv.buildPlatform.canExecute stdenv.hostPlatform) (
      if (lib.versionOlder release_version "19") then
        ''
          substituteInPlace CMakeLists.txt \
            --replace-fail 'COMMAND prepare_builtins' \
                           'COMMAND ${buildLlvmPackages.libclc.dev}/bin/prepare_builtins'
        ''
      else
        ''
          substituteInPlace CMakeLists.txt \
            --replace-fail 'set( prepare_builtins_exe prepare_builtins )' \
                           'set( prepare_builtins_exe ${buildLlvmPackages.libclc.dev}/bin/prepare_builtins )'
        ''
    );

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    ninja
    python3
  ]
  ++ lib.optionals (lib.versionAtLeast release_version "19") [
    clang-only
    llvm
    spirv-llvm-translator
  ];

  buildInputs = [ llvm ];

  postInstall = lib.optionalString (lib.versionOlder finalAttrs.version "22.1") ''
    install -Dt $dev/bin prepare_builtins
  '';

  sourceRoot = "${finalAttrs.src.name}/libclc";

  meta = {
    description = "Implementation of the library requirements of the OpenCL C programming language";
    homepage = "http://libclc.llvm.org/";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
    mainProgram = "prepare_builtins";
  };
})
