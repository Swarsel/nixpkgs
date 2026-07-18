{
  lib,
  stdenv,
  fetchFromGitHub,
  cairo,
  gettext,
  glib,
  libdrm,
  libinput,
  libpng,
  librsvg,
  libsfdo,
  libxcb,
  libxcb-wm,
  libxkbcommon,
  libxml2,
  meson,
  ninja,
  pango,
  pkg-config,
  scdoc,
  versionCheckHook,
  wayland,
  wayland-protocols,
  wayland-scanner,
  wlroots_0_20,
  xwayland,
  enableSystemd ? true,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "labwc";
  version = "0.20.1";

  src = fetchFromGitHub {
    owner = "labwc";
    repo = "labwc";
    tag = finalAttrs.version;
    hash = "sha256-1LINOZsdN5btT0VQvUwYXbSjuKdQdbkaI062OYAJSiE=";
  };

  outputs = [
    "out"
    "doc"
    "man"
  ];

  postPatch = ''
    substituteInPlace meson.build \
      --replace-fail "install_dir: systemd.get_variable('systemduserunitdir')" \
                     "install_dir: '$out/lib/systemd/user'"
  '';

  strictDeps = true;

  nativeBuildInputs = [
    gettext
    meson
    ninja
    pkg-config
    scdoc
    wayland-scanner
  ];

  buildInputs = [
    cairo
    glib
    libdrm
    libinput
    libpng
    librsvg
    libsfdo
    libxcb
    libxkbcommon
    libxml2
    pango
    wayland
    wayland-protocols
    wlroots_0_20
    libxcb-wm
    xwayland
  ];

  mesonFlags = [
    (lib.mesonEnable "xwayland" true)
    (lib.mesonEnable "systemd-session" enableSystemd)
  ];

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  passthru = {
    providedSessions = [ "labwc" ];
  };

  meta = {
    inherit (wayland.meta) platforms;
    description = "Wayland stacking compositor, inspired by Openbox";
    homepage = "https://github.com/labwc/labwc";
    changelog = "https://github.com/labwc/labwc/blob/master/NEWS.md";
    license = with lib.licenses; [ gpl2Plus ];
    maintainers = [ ];
    mainProgram = "labwc";
  };
})
