{
  lib,
  stdenv,
  fetchFromGitHub,
  boost,
  catch2_3,
  cmake,
  fetchpatch,
  fmt,
  mimalloc,
  ninja,
  python3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "sv-lang";
  version = "10.0";

  src = fetchFromGitHub {
    owner = "MikePopoloski";
    repo = "slang";
    tag = "v${finalAttrs.version}";
    hash = "sha256-rw+DztENuY+DiAhQR2oNN/dQJzrcP5neF3LoWnqri+c=";
  };

  patches = [
    (fetchpatch {
      hash = "sha256-Evx5HJk8fH3QoBXM5BE3tmdJVnblVTkxLMTNIRLOt/c=";
      url = "https://github.com/MikePopoloski/slang/commit/0e2094e3570f399c4bedff8c7cf342812b50d909.patch";
    })
  ];

  postPatch = ''
    substituteInPlace external/CMakeLists.txt --replace-fail \
      'set(mimalloc_min_version "2.2")' \
      'set(mimalloc_min_version "${lib.versions.majorMinor mimalloc.version}")'
  '';

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    python3
    ninja
  ];

  buildInputs = [
    boost
    fmt
    mimalloc
    catch2_3
  ];

  cmakeFlags = [
    "-DCMAKE_INSTALL_INCLUDEDIR=include"
    "-DCMAKE_INSTALL_LIBDIR=lib"
    "-DSLANG_INCLUDE_TESTS=${if finalAttrs.finalPackage.doCheck then "ON" else "OFF"}"
    # CIRCT disables threading to avoid a race condition in BS::thread_pool:
    # https://github.com/llvm/circt/blob/firtool-1.147.0/CMakeLists.txt#L579
    # This may be parameterized if other packages depend on this package.
    "-DSLANG_USE_THREADS=OFF"
  ];

  doCheck = !stdenv.hostPlatform.isDarwin;
  __structuredAttrs = true;

  meta = {
    description = "SystemVerilog compiler and language services";
    homepage = "https://github.com/MikePopoloski/slang";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ sharzy ];
    platforms = lib.platforms.all;
    mainProgram = "slang";
    broken = stdenv.hostPlatform.isDarwin;
  };
})
