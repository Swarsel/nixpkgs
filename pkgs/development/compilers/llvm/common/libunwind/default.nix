{
  lib,
  stdenv,
  cmake,
  getVersionFile,
  libcxx,
  llvm_meta,
  ninja,
  python3,
  release_version,
  runCommand,
  version,
  devExtraCmakeFlags ? [ ],
  doFakeLibgcc ? stdenv.hostPlatform.useLLVM && !stdenv.hostPlatform.isStatic,
  enableShared ? !stdenv.hostPlatform.isStatic,
  monorepoSrc ? null,
  src ? null,
}:
stdenv.mkDerivation (finalAttrs: {
  inherit version;
  pname = "libunwind";

  src =
    if monorepoSrc != null then
      runCommand "libunwind-src-${version}" { inherit (monorepoSrc) passthru; } ''
        mkdir -p "$out"
        cp -r ${monorepoSrc}/cmake "$out"
        cp -r ${monorepoSrc}/libunwind "$out"
        mkdir -p "$out/libcxx"
        cp -r ${monorepoSrc}/libcxx/cmake "$out/libcxx"
        cp -r ${monorepoSrc}/libcxx/utils "$out/libcxx"
        mkdir -p "$out/llvm"
        cp -r ${monorepoSrc}/llvm/cmake "$out/llvm"
        cp -r ${monorepoSrc}/llvm/utils "$out/llvm"
        cp -r ${monorepoSrc}/runtimes "$out"
      ''
    else
      src;

  outputs = [
    "out"
    "dev"
  ];

  nativeBuildInputs = [
    cmake
    ninja
    python3
  ];

  cmakeFlags = [
    (lib.cmakeBool "LIBUNWIND_ENABLE_SHARED" enableShared)
    (lib.cmakeFeature "LLVM_ENABLE_RUNTIMES" "libunwind")
  ]
  ++ devExtraCmakeFlags;

  postInstall =
    lib.optionalString (enableShared && !stdenv.hostPlatform.isDarwin && !stdenv.hostPlatform.isWindows)
      ''
        # libcxxabi wants to link to libunwind_shared.so (?).
        ln -s $out/lib/libunwind.so $out/lib/libunwind_shared.so
      ''
    + lib.optionalString (enableShared && stdenv.hostPlatform.isWindows) ''
      ln -s $out/lib/libunwind.dll.a $out/lib/libunwind_shared.dll.a
    ''
    + lib.optionalString (doFakeLibgcc && !stdenv.hostPlatform.isWindows) ''
      ln -s $out/lib/libunwind.so $out/lib/libgcc_s.so
      ln -s $out/lib/libunwind.so $out/lib/libgcc_s.so.1
    ''
    + lib.optionalString (doFakeLibgcc && stdenv.hostPlatform.isWindows) ''
      ln -s $out/lib/libunwind.dll.a $out/lib/libgcc_s.dll.a
    '';

  sourceRoot = "${finalAttrs.src.name}/runtimes";

  meta = llvm_meta // {
    description = "LLVM's unwinder library";

    longDescription = ''
      The unwind library provides a family of _Unwind_* functions implementing
      the language-neutral stack unwinding portion of the Itanium C++ ABI (Level
      I). It is a dependency of the C++ ABI library, and sometimes is a
      dependency of other runtimes.
    '';

    # Details: https://github.com/llvm/llvm-project/blob/main/libunwind/docs/index.rst
    homepage = "https://clang.llvm.org/docs/Toolchain.html#unwind-library";
  };
})
