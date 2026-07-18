{
  lib,
  fetchFromGitLab,
  meson,
  ninja,
  pkg-config,
  stdenvNoCC,
  testers,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "hicolor-icon-theme";
  version = "0.18";

  src = fetchFromGitLab {
    owner = "xdg";
    repo = "default-icon-theme";
    rev = "v${finalAttrs.version}";
    hash = "sha256-uoB7u/ok7vMxKDl8pINdnV9VsvmsntBcZuz3Q4zGz7M=";
    domain = "gitlab.freedesktop.org";
  };

  outputs = [
    "out"
    "dev"
  ];

  nativeBuildInputs = [
    meson
    pkg-config
    ninja
  ];

  setupHook = ./setup-hook.sh;
  passthru.tests.pkg-config = testers.testMetaPkgConfig finalAttrs.finalPackage;

  meta = {
    description = "Default fallback theme used by implementations of the icon theme specification";
    homepage = "https://www.freedesktop.org/wiki/Software/icon-theme/";
    changelog = "https://gitlab.freedesktop.org/xdg/default-icon-theme/-/blob/${finalAttrs.src.rev}/NEWS";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ jopejoe1 ];
    platforms = lib.platforms.unix;
    pkgConfigModules = [ "default-icon-theme" ];
  };
})
