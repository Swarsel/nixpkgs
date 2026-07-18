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
  pname = "highscore-stella";
  version = "0-unstable-2026-06-01";

  src = fetchFromGitHub {
    owner = "highscore-emu";
    repo = "stella";
    rev = "f1572c44150d1e772e4d1f4e6ff4284ac8609905";
    hash = "sha256-ly5jkz6LewoZXon2z77EdPnnGqnp4cbTQQuJsRffuxg=";
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
  ];

  sourceRoot = "${finalAttrs.src.name}/src/os/highscore";

  passthru.updateScript = unstableGitUpdater {
    hardcodeZeroVersion = true;
  };

  meta = {
    inherit (libhighscore.meta) maintainers platforms;
    description = "Port of Stella to Highscore";
    homepage = "https://github.com/highscore-emu/stella";
    license = lib.licenses.gpl2Only;
  };
})
