{
  lib,
  stdenv,
  fetchFromGitHub,
  deadbeef,
  ffmpeg,
  libvorbis,
  mpg123,
  nix-update-script,
  pkg-config,
  vgmstream,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "deadbeef-vgmstream-plugin";
  version = "2026-06-22";

  src = fetchFromGitHub {
    owner = "jchv";
    repo = "deadbeef-vgmstream";
    rev = finalAttrs.version;
    hash = "sha256-pX6uhrLgJ2sWwm2tR45YuYbICrP8fKgOD/TXV79bHn4=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    deadbeef
    mpg123
    libvorbis
    ffmpeg.dev
  ];

  makeFlags = [ "DEADBEEF_ROOT=${deadbeef}" ];
  enableParallelBuilding = true;
  installFlags = [ "DEADBEEF_ROOT=$(out)" ];

  postUnpack = ''
    rm -rf $sourceRoot/vgmstream
    cp --no-preserve=mode,ownership -LR ${vgmstream.src} $sourceRoot/vgmstream
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Streaming video game music decoder plugin for the DeaDBeeF music player";
    homepage = "https://github.com/jchv/deadbeef-vgmstream";
    license = lib.licenses.isc;
    maintainers = [ lib.maintainers.jchw ];
    platforms = lib.platforms.linux;
  };
})
