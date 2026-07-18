{
  lib,
  stdenv,
  cmake,
  fetchpatch,
  llvm,
  python3,
  rocm-device-libs,
  zlib,
  zstd,
}:

let
  llvmNativeTarget =
    if stdenv.hostPlatform.isx86_64 then
      "X86"
    else if stdenv.hostPlatform.isAarch64 then
      "AArch64"
    else
      throw "Unsupported ROCm LLVM platform";
in
stdenv.mkDerivation (finalAttrs: {
  # In-tree with ROCm LLVM
  inherit (llvm.llvm) version;
  pname = "rocm-comgr";
  src = llvm.llvm.monorepoSrc;

  patches = [
    # [Comgr] Extend ISA compatibility
    (fetchpatch {
      hash = "sha256-X2VPGigK582J+a/u2Kg74w25/+CTpVWU9D3Eqgnb2PU=";
      relative = "amd/comgr";
      url = "https://github.com/GZGavinZhao/rocm-llvm-project/commit/7002dc04863d38c57cfd2e6fc60a1cf5a613fd8e.patch";
    })
    # [Comgr] Extend ISA compatibility for CCOB
    (fetchpatch {
      hash = "sha256-/50I+PqxL3oaQMqg5vR7+ibUcXO1SvfXBdw/sybRt1o=";
      relative = "amd/comgr";
      url = "https://github.com/GZGavinZhao/rocm-llvm-project/commit/2c1e44fc3eacadcafdd4ada3e3184a092b6f26c5.patch";
    })
    # Fix: CCOB compat patch used coerced (featureless) name for output filename,
    # causing CLR's code_obj_map key to miss when looking up device ISA with features
    ./fix-ccob-compat-output-filename.patch
  ];

  postPatch =
    # Fix relative path assumption for libllvm
    ''
      substituteInPlace cmake/opencl_header.cmake \
        --replace-fail "\''${CLANG_CMAKE_DIR}/../../../" "${llvm.clang-unwrapped.lib}"
    ''
    # Bake LLVM root for cfg/includes or HIPRTC can't find C++ stdlib headers (e.g. <type_traits>).
    + ''
      substituteInPlace src/comgr-env.cpp \
        --replace-fail \
          'return EnvLLVMPath;' \
          'return EnvLLVMPath ? EnvLLVMPath : "${llvm.rocm-toolchain}";'
    '';

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    python3
  ];

  buildInputs = [
    llvm.llvm
    llvm.clang-unwrapped
    llvm.lld
    rocm-device-libs
    zlib
    zstd
  ];

  cmakeFlags = [
    "-DLLVM_TARGETS_TO_BUILD=AMDGPU;${llvmNativeTarget}"
  ];

  sourceRoot = "${finalAttrs.src.name}/amd/comgr";

  meta = {
    description = "APIs for compiling and inspecting AMDGPU code objects";
    homepage = "https://github.com/ROCm/ROCm-CompilerSupport/tree/amd-stg-open/lib/comgr";
    license = lib.licenses.ncsa;
    maintainers = with lib.maintainers; [ lovesegfault ];
    platforms = lib.platforms.linux;
    teams = [ lib.teams.rocm ];
  };
})
