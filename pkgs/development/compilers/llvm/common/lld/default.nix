{
  lib,
  stdenv,
  buildLlvmPackages,
  cmake,
  fetchpatch,
  getVersionFile,
  libllvm,
  libxml2,
  llvm_meta,
  ninja,
  release_version,
  runCommand,
  version,
  devExtraCmakeFlags ? [ ],
  monorepoSrc ? null,
  src ? null,
}:
stdenv.mkDerivation (finalAttrs: {
  inherit version;
  pname = "lld";

  src =
    if monorepoSrc != null then
      runCommand "lld-src-${version}" { inherit (monorepoSrc) passthru; } ''
        mkdir -p "$out"
        cp -r ${monorepoSrc}/cmake "$out"
        cp -r ${monorepoSrc}/lld "$out"
        mkdir -p "$out/libunwind"
        cp -r ${monorepoSrc}/libunwind/include "$out/libunwind"
        mkdir -p "$out/llvm"
      ''
    else
      src;

  outputs = [
    "out"
    "lib"
    "dev"
  ];

  patches = [
    (getVersionFile "lld/gnu-install-dirs.patch")
  ]
  ++ lib.optional (lib.versions.major release_version == "18") (
    # https://github.com/llvm/llvm-project/pull/97122
    fetchpatch {
      hash = "sha256-7wTy7XDTx0+fhWQpW1KEuz7xJvpl42qMTUfd20KGOfA=";
      name = "more-openbsd-program-headers.patch";
      stripLen = 1;
      url = "https://github.com/llvm/llvm-project/commit/d7fd8b19e560fbb613159625acd8046d0df75115.patch";
    }
  );

  nativeBuildInputs = [
    cmake
    ninja
  ];

  buildInputs = [
    libllvm
    libxml2
  ];

  cmakeFlags = [
    (lib.cmakeFeature "LLD_INSTALL_PACKAGE_DIR" "${placeholder "dev"}/lib/cmake/lld")
    (lib.cmakeFeature "LLVM_TABLEGEN_EXE" "${buildLlvmPackages.tblgen}/bin/llvm-tblgen")
  ]
  ++ devExtraCmakeFlags;

  # Musl's default stack size is too small for lld to be able to link Firefox.
  env = lib.optionalAttrs stdenv.hostPlatform.isMusl {
    LDFLAGS = "-Wl,-z,stack-size=2097152";
  };

  sourceRoot = "${finalAttrs.src.name}/lld";

  meta = llvm_meta // {
    description = "LLVM linker (unwrapped)";

    longDescription = ''
      LLD is a linker from the LLVM project that is a drop-in replacement for
      system linkers and runs much faster than them. It also provides features
      that are useful for toolchain developers.
      The linker supports ELF (Unix), PE/COFF (Windows), Mach-O (macOS), and
      WebAssembly in descending order of completeness. Internally, LLD consists
      of several different linkers.
    '';

    homepage = "https://lld.llvm.org/";
  };
})
