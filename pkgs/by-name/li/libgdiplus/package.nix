{
  lib,
  stdenv,
  fetchFromGitLab,
  autoreconfHook,
  cairo,
  fontconfig,
  giflib,
  glib,
  libexif,
  libjpeg,
  libpng,
  libtiff,
  libxrender,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libgdiplus";
  version = "6.2";

  src = fetchFromGitLab {
    owner = "mono";
    repo = "libgdiplus";
    tag = finalAttrs.version;
    hash = "sha256-otWdHiS/Ws+2tq5wQlcSfBUOc8Mfhpz5PLmMDgtld1Q=";
    domain = "gitlab.winehq.org";
  };

  outputs = [
    "out"
    "dev"
  ];

  patches = [
    # Fix pkg-config lookup when cross-compiling.
    ./configure-pkg-config.patch
  ];

  postPatch = ''
    substituteInPlace Makefile.am \
      --replace-fail "all: update_submodules" "all:"
  '';

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];

  buildInputs = [
    glib
    cairo
    fontconfig
    libtiff
    giflib
    libjpeg
    libpng
    libxrender
    libexif
  ];

  configureFlags = lib.optional stdenv.cc.isClang "--host=${stdenv.hostPlatform.system}";
  env.NIX_LDFLAGS = "-lgif";

  checkPhase = ''
    make check -w
  '';

  postInstall = lib.optionalString stdenv.hostPlatform.isDarwin ''
    ln -s $out/lib/libgdiplus.0.dylib $out/lib/libgdiplus.so
  '';

  enableParallelBuilding = true;
  hardeningDisable = [ "format" ];

  meta = {
    description = "Mono library that provides a GDI+-compatible API on non-Windows operating systems";
    homepage = "https://www.mono-project.com/docs/gui/libgdiplus/";
    changelog = "https://gitlab.winehq.org/mono/libgdiplus/-/releases/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
  };
})
