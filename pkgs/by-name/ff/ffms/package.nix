{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  ffmpeg,
  pkg-config,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ffms";
  version = "5.0";

  src = fetchFromGitHub {
    owner = "FFMS";
    repo = "ffms2";
    rev = finalAttrs.version;
    sha256 = "sha256-Ildl8hbKSFGh4MUBK+k8uYMDrOZD9NSMdPAWIIaGy4E=";
  };

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];

  buildInputs = [
    ffmpeg
    zlib
  ];

  env.NIX_CFLAGS_COMPILE = "-fPIC";

  # ffms includes a built-in vapoursynth plugin, see:
  # https://github.com/FFMS/ffms2#avisynth-and-vapoursynth-plugin
  postInstall = ''
    mkdir $out/lib/vapoursynth
    ln -s $out/lib/libffms2${stdenv.hostPlatform.extensions.sharedLibrary} $out/lib/vapoursynth/libffms2${stdenv.hostPlatform.extensions.sharedLibrary}
  '';

  preAutoreconf = ''
    mkdir src/config
  '';

  meta = {
    description = "FFmpeg based source library for easy frame accurate access";
    homepage = "https://github.com/FFMS/ffms2";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ wegank ];
    platforms = lib.platforms.unix;
    mainProgram = "ffmsindex";
  };
})
