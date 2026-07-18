{
  lib,
  stdenv,
  fetchFromGitHub,
  alsa-lib,
  gettext,
  meson,
  ninja,
  nix-update-script,
  pkg-config,
  vala,
  xfce4-panel,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "xfce4-alsa-plugin";
  version = "0.4.0";

  src = fetchFromGitHub {
    owner = "equeim";
    repo = "xfce4-alsa-plugin";
    tag = finalAttrs.version;
    hash = "sha256-95uVHDyXji8dut7qfE5V/uBBt6DPYF/YfudHe7HJcE8=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    meson
    vala
    pkg-config
    gettext
    ninja
  ];

  buildInputs = [
    alsa-lib
    xfce4-panel
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Simple ALSA volume control for xfce4-panel";
    homepage = "https://github.com/equeim/xfce4-alsa-plugin";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ ProxyVT ];
    platforms = lib.platforms.linux;
    teams = [ lib.teams.xfce ];
  };
})
