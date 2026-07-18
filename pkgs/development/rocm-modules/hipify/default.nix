{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  llvm,
  perl,
  rocmUpdateScript,
  zlib,
  zstd,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "hipify";
  version = "7.2.3";

  src = fetchFromGitHub {
    owner = "ROCm";
    repo = "HIPIFY";
    rev = "rocm-${finalAttrs.version}";
    hash = "sha256-LC0lnYetV7RPVw92zew6za6bDH4zmnERXUM4MVaRVtc=";
  };

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace-fail "\''${LLVM_TOOLS_BINARY_DIR}/clang" "${llvm.rocm-toolchain}/bin/clang"
    chmod +x bin/*
  '';

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    perl
    llvm.rocm-toolchain
  ];

  buildInputs = [
    llvm.llvm
    llvm.clang-unwrapped
    perl
    zlib
    zstd
  ];

  env.CXXFLAGS = "-I${lib.getInclude llvm.llvm}/include -I${lib.getInclude llvm.clang-unwrapped}/include";

  postInstall = ''
    rm $out/bin/hipify-perl
    chmod +x $out/bin/*
    chmod +x $out/libexec/*
    patchShebangs $out/bin/
    patchShebangs $out/libexec/
    ln -s $out/{libexec/hipify,bin}/hipify-perl
  '';

  passthru.updateScript = rocmUpdateScript { inherit finalAttrs; };

  meta = {
    description = "Convert CUDA to Portable C++ Code";
    homepage = "https://github.com/ROCm/HIPIFY";
    license = with lib.licenses; [ mit ];
    platforms = lib.platforms.linux;
    teams = [ lib.teams.rocm ];
  };
})
