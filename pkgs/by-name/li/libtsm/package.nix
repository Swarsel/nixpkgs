{
  lib,
  stdenv,
  fetchFromGitHub,
  check,
  libxkbcommon,
  meson,
  ninja,
  nix-update-script,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libtsm";
  version = "4.6.0";

  src = fetchFromGitHub {
    owner = "kmscon";
    repo = "libtsm";
    tag = "v${finalAttrs.version}";
    hash = "sha256-CN5ktki8fbvmiGiyDvDf4ayRKakpWRI51SdhRbFqNVM=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
  ];

  buildInputs = [
    libxkbcommon
    check
  ];

  __structuredAttrs = true;
  passthru.updateScript = nix-update-script { extraArgs = [ "--use-github-releases" ]; };

  meta = {
    description = "Terminal-emulator State Machine";
    homepage = "https://www.freedesktop.org/wiki/Software/kmscon/libtsm/";
    changelog = "https://github.com/kmscon/libtsm/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ccicnce113424 ];
    platforms = lib.platforms.linux;
  };
})
