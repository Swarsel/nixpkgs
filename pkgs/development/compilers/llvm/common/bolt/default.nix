{
  lib,
  stdenv,
  buildLlvmPackages,
  cmake,
  fetchpatch,
  libclang,
  libllvm,
  libxml2,
  llvm_meta,
  monorepoSrc,
  ninja,
  python3,
  release_version,
  runCommand,
  version,
  devExtraCmakeFlags ? [ ],
  patches ? [ ],
}:

stdenv.mkDerivation (finalAttrs: {
  inherit version;
  pname = "bolt";

  # Blank llvm dir just so relative path works
  src = runCommand "bolt-src-${finalAttrs.version}" { inherit (monorepoSrc) passthru; } ''
    mkdir $out
    cp -r ${monorepoSrc}/cmake "$out"
    cp -r ${monorepoSrc}/${finalAttrs.pname} "$out"
    cp -r ${monorepoSrc}/third-party "$out"

    # BOLT re-runs tablegen against LLVM sources, so needs them available.
    cp -r ${monorepoSrc}/llvm/ "$out"
    chmod -R +w $out/llvm
  '';

  outputs = [
    "out"
    "dev"
  ];

  patches = lib.optionals (lib.versions.major release_version == "19") [
    (fetchpatch {
      hash = "sha256-oxCxOjhi5BhNBEraWalEwa1rS3Mx9CuQgRVZ2hrbd7M=";
      url = "https://github.com/llvm/llvm-project/commit/abc2eae68290c453e1899a94eccc4ed5ea3b69c1.patch";
    })
    (fetchpatch {
      hash = "sha256-l4rQHYbblEADBXaZIdqTG0sZzH4fEQvYiqhLYNZDMa8=";
      url = "https://github.com/llvm/llvm-project/commit/5909979869edca359bcbca74042c2939d900680e.patch";
    })
  ];

  postPatch = ''
    cd bolt
  '';

  nativeBuildInputs = [
    cmake
    ninja
    python3
  ];

  buildInputs = [
    libllvm
    libxml2
  ];

  cmakeFlags = [
    (lib.cmakeFeature "LLVM_TABLEGEN_EXE" "${buildLlvmPackages.tblgen}/bin/llvm-tblgen")
  ]
  ++ devExtraCmakeFlags;

  postInstall = ''
    mkdir -p $dev/lib
    mv $out/lib/libLLVMBOLT*.a $dev/lib
  '';

  postUnpack = ''
    chmod -R u+w -- $sourceRoot/..
  '';

  prePatch = ''
    cd ..
  '';

  sourceRoot = "${finalAttrs.src.name}/bolt";

  meta = llvm_meta // {
    description = "LLVM post-link optimizer";
    homepage = "https://github.com/llvm/llvm-project/tree/main/bolt";
  };
})
