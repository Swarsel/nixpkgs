{
  lib,
  stdenv,
  fetchFromGitHub,
  libchdr,
  libhighscore,
  libvorbis,
  meson,
  ninja,
  pkg-config,
  unstableGitUpdater,
  zstd,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "highscore-mednafen";
  version = "0-unstable-2026-05-22";

  src = fetchFromGitHub {
    owner = "highscore-emu";
    repo = "mednafen-highscore";
    rev = "e13c337a2cde6d5304f2a33311447280ef206a7a";
    hash = "sha256-nwvOkL1RzqXCqMFiDuSvNhgmujvxFYpdp4OScvEmppI=";
  };

  postPatch = ''
    substituteInPlace meson.build \
      --replace-fail "run_command('git', 'describe', '--always', '--dirty', check: false).stdout().strip()" \
        "'${finalAttrs.src.rev}'"
  '';

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
  ];

  buildInputs = [
    libhighscore
    zstd
    libchdr
    libvorbis
  ];

  sourceRoot = "${finalAttrs.src.name}/highscore";

  passthru.updateScript = unstableGitUpdater {
    hardcodeZeroVersion = true;
  };

  meta = {
    inherit (libhighscore.meta) maintainers platforms;
    description = "Port of Mednafen to Highscore";
    homepage = "https://github.com/highscore-emu/mednafen-highscore";
    license = lib.licenses.gpl2Plus;
  };
})
