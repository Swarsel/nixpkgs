{
  lib,
  stdenv,
  cmake,
  llvm,
  ninja,
  python3,
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
  pname = "rocm-device-libs";
  src = llvm.llvm.monorepoSrc;

  patches = [
    ./cmake.patch
  ];

  postPatch =
    # Use our sysrooted toolchain instead of direct clang target
    ''
      substituteInPlace cmake/OCL.cmake \
        --replace-fail '$<TARGET_FILE:clang>' "${llvm.rocm-toolchain}/bin/clang"
    '';

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    ninja
    python3
    llvm.rocm-toolchain
  ];

  buildInputs = [
    llvm.llvm
    llvm.clang-unwrapped
    zlib
    zstd
  ];

  cmakeFlags = [
    "-DLLVM_TARGETS_TO_BUILD=AMDGPU;${llvmNativeTarget}"
  ];

  __structuredAttrs = true;
  sourceRoot = "${finalAttrs.src.name}/amd/device-libs";

  meta = {
    description = "Set of AMD-specific device-side language runtime libraries";
    homepage = "https://github.com/ROCm/ROCm-Device-Libs";
    license = lib.licenses.ncsa;
    maintainers = with lib.maintainers; [ lovesegfault ];
    platforms = lib.platforms.linux;
    teams = [ lib.teams.rocm ];
  };
})
