{
  lib,
  stdenv,
  fetchFromGitHub,
  SDL2,
  SDL2_ttf,
  ffmpeg,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "video-compare";
  version = "20260708";

  src = fetchFromGitHub {
    owner = "pixop";
    repo = "video-compare";
    tag = finalAttrs.version;
    hash = "sha256-4wmbw+6BBMl+dY6UXYDFAyHA7RRHPwqhppn52Tkvz2k=";
  };

  postPatch = ''
    # Fix build on Darwin by using $CXX set by setup-hook
    substituteInPlace makefile \
      --replace-fail 'CXX = g++' ""
  '';

  buildInputs = [
    SDL2
    SDL2_ttf
    ffmpeg
  ];

  env.NIX_CFLAGS_COMPILE = "-I${lib.getDev SDL2}/include/SDL2";

  installPhase = ''
    runHook preInstall

    install -Dt $out/bin video-compare

    runHook postInstall
  '';

  enableParallelBuilding = true;

  meta = {
    description = "Split screen video comparison tool";
    homepage = "https://github.com/pixop/video-compare";
    license = lib.licenses.gpl2Only;
    maintainers = [ ];
    platforms = lib.platforms.unix;
    mainProgram = "video-compare";
  };
})
