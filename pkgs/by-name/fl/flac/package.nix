{
  lib,
  stdenv,
  fetchurl,
  buildPackages,
  cmake,
  doxygen,
  graphviz,
  libogg,
  nix-update-script,
  pkg-config,
  versionCheckHook,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "flac";
  version = "1.5.0";

  # Building from tarball instead of GitHub to include pre-built manpages.
  # This prevents huge numbers of rebuilds for pandoc / haskell-updates.
  # It also enables manpages for platforms where pandoc is not available.
  src = fetchurl {
    url = "https://downloads.xiph.org/releases/flac/flac-${finalAttrs.version}.tar.xz";
    hash = "sha256-8sHHZZKoL//4QTujxKEpm2x6sGxzTe4D/YhjBIXCuSA=";
  };

  outputs = [
    "bin"
    "dev"
    "doc"
    "out"
    "man"
  ];

  patches = [ ./package.patch ];

  nativeBuildInputs = [
    cmake
    doxygen
    graphviz
    pkg-config
  ];

  buildInputs = [ libogg ];

  cmakeFlags = lib.optionals (!stdenv.hostPlatform.isStatic) [
    "-DBUILD_SHARED_LIBS=ON"
  ];

  env = {
    CFLAGS = toString [
      "-O3"
      "-funroll-loops"
    ];

    CXXFLAGS = toString [ "-O3" ];
  };

  doCheck = true;
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  hardeningDisable = [ "trivialautovarinit" ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Library and tools for encoding and decoding the FLAC lossless audio file format";
    homepage = "https://xiph.org/flac/";
    changelog = "https://github.com/xiph/flac/releases/tag/${finalAttrs.version}";

    license = with lib.licenses; [
      bsd3
      fdl13Plus
      gpl2Plus
      lgpl21Plus
    ];

    maintainers = with lib.maintainers; [ ruuda ];
    platforms = lib.platforms.all;
    mainProgram = "flac";
  };
})
