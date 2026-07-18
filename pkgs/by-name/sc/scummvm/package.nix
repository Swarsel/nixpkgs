{
  lib,
  stdenv,
  fetchFromGitHub,
  SDL2,
  alsa-lib,
  cctools,
  curl,
  flac,
  fluidsynth,
  freetype,
  libGL,
  libGLU,
  libjpeg,
  libmad,
  libmpeg2,
  libogg,
  libtheora,
  libvorbis,
  libx11,
  nasm,
  nix-update-script,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "scummvm";
  version = "2026.1.0";

  src = fetchFromGitHub {
    owner = "scummvm";
    repo = "scummvm";
    rev = "v${finalAttrs.version}";
    hash = "sha256-wgMOhQ6yHk4dG94J4EdHTxsaCqapyFhJU1GjRuQY8TY=";
  };

  nativeBuildInputs = [ nasm ];

  buildInputs =
    lib.optionals stdenv.hostPlatform.isLinux [
      alsa-lib
      libGLU
      libGL
    ]
    ++ [
      curl
      freetype
      flac
      fluidsynth
      libjpeg
      libmad
      libmpeg2
      libogg
      libtheora
      libvorbis
      SDL2
      libx11
      zlib
    ];

  configureFlags = [
    "--enable-release"
  ];

  env.NIX_CFLAGS_COMPILE = toString [ "-fpermissive" ];

  # They use 'install -s', that calls the native strip instead of the cross
  postConfigure = ''
    sed -i "s/-c -s/-c -s --strip-program=''${STRIP@Q}/" ports.mk
  ''
  + lib.optionalString stdenv.hostPlatform.isDarwin ''
    substituteInPlace config.mk \
      --replace-fail ${stdenv.hostPlatform.config}-ranlib ${cctools}/bin/ranlib
  '';

  configurePlatforms = [ "host" ];
  dontDisableStatic = true;
  enableParallelBuilding = true;

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Program to run certain classic graphical point-and-click adventure games (such as Monkey Island)";
    homepage = "https://www.scummvm.org/";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ peterhoeg ];
    platforms = lib.platforms.unix;
    mainProgram = "scummvm";
  };
})
