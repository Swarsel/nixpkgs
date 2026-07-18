{
  lib,
  stdenv,
  fetchFromGitHub,
  libhighscore,
  meson,
  ninja,
  pkg-config,
  unstableGitUpdater,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "highscore-blastem";
  version = "0-unstable-2025-06-28";

  src = fetchFromGitHub {
    owner = "highscore-emu";
    repo = "blastem-highscore";
    rev = "d19e9a8ddd0accf017f44dcc81bdd2661f63f25f";
    hash = "sha256-KetitwqL4S0T4GayeTdwR5hG/LVUF+mJ8oGIN6XPLfU=";
  };

  postPatch = ''
    patchShebangs gen-db.sh

    substituteInPlace meson.build \
      --replace-fail "run_command('git', 'describe', '--always', '--dirty').stdout().strip()" \
        "'${finalAttrs.src.rev}'"
  '';

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
  ];

  buildInputs = [
    libhighscore
  ];

  sourceRoot = "${finalAttrs.src.name}/highscore";

  passthru.updateScript = unstableGitUpdater {
    hardcodeZeroVersion = true;
  };

  meta = {
    inherit (libhighscore.meta) maintainers platforms;
    description = "Port of BlastEm to Highscore";
    homepage = "https://github.com/highscore-emu/blastem-highscore";
    license = lib.licenses.gpl3Plus;
    badPlatforms = lib.platforms.aarch64;
  };
})
