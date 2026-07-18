{
  lib,
  stdenv,
  cmake,
  llvm,
  lsb-release,
}:

stdenv.mkDerivation (finalAttrs: {
  # In-tree with ROCm LLVM
  inherit (llvm.llvm) version;
  pname = "hipcc";
  src = llvm.llvm.monorepoSrc;

  postPatch = ''
    substituteInPlace src/hipBin_amd.h \
      --replace-fail "/usr/bin/lsb_release" "${lsb-release}/bin/lsb_release"
  '';

  strictDeps = true;

  nativeBuildInputs = [
    llvm.rocm-toolchain
    cmake
  ];

  buildInputs = [
    llvm.clang-unwrapped
  ];

  cmakeFlags = [
    "-DCMAKE_BUILD_TYPE=Release"
  ];

  postInstall = ''
    rm -r $out/hip/bin
    ln -s $out/bin $out/hip/bin
  '';

  sourceRoot = "${finalAttrs.src.name}/amd/hipcc";

  meta = {
    description = "Compiler driver utility that calls clang or nvcc";
    homepage = "https://github.com/ROCm/HIPCC";
    license = with lib.licenses; [ mit ];
    maintainers = with lib.maintainers; [ lovesegfault ];
    platforms = lib.platforms.linux;
    teams = [ lib.teams.rocm ];
  };
})
