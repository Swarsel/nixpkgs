{
  lib,
  stdenv,
  fetchurl,
  autoreconfHook,
  freetype,
  guile,
  guile-chickadee,
  guile-opengl,
  guile-sdl2,
  libjpeg_turbo,
  libpng,
  libvorbis,
  makeWrapper,
  mpg123,
  openal,
  pkg-config,
  readline,
  testers,
  texinfo,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "guile-chickadee";
  version = "0.10.0";

  src = fetchurl {
    url = "https://files.dthompson.us/chickadee/chickadee-${finalAttrs.version}.tar.gz";
    hash = "sha256-Ey9TtuWaGlHG2cYYwqJIt2RX7XNUW28OGl/kuPUCD3U=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    makeWrapper
    autoreconfHook
    guile
    pkg-config
    texinfo
  ];

  buildInputs = [
    freetype
    guile
    libjpeg_turbo
    libpng
    libvorbis
    mpg123
    openal
    readline
  ];

  propagatedBuildInputs = [
    guile-opengl
    guile-sdl2
  ];

  makeFlags = [ "GUILE_AUTO_COMPILE=0" ];
  doCheck = !stdenv.hostPlatform.isDarwin;

  postInstall = ''
    wrapProgram $out/bin/chickadee \
      --prefix GUILE_LOAD_PATH : "$out/${guile.siteDir}:$GUILE_LOAD_PATH" \
      --prefix GUILE_LOAD_COMPILED_PATH : "$out/${guile.siteCcacheDir}:$GUILE_LOAD_COMPILED_PATH"
  '';

  passthru.tests.version = testers.testVersion {
    command = "chickadee -v";
    package = guile-chickadee;
  };

  meta = {
    description = "Game development toolkit for Guile Scheme with SDL2 and OpenGL";
    homepage = "https://dthompson.us/projects/chickadee.html";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ chito ];
    platforms = guile.meta.platforms;
    mainProgram = "chickadee";
    broken = stdenv.hostPlatform.isDarwin;
  };
})
