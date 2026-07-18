{
  lib,
  stdenv,
  fetchFromGitHub,
  blueprint-compiler,
  desktop-file-utils,
  glib,
  gtk4,
  gusb,
  libadwaita,
  meson,
  ninja,
  nix-update-script,
  pkg-config,
  vala,
  wrapGAppsHook4,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "nxdumpclient";
  version = "1.1.4";

  src = fetchFromGitHub {
    owner = "v1993";
    repo = "nxdumpclient";
    tag = "v${finalAttrs.version}";
    hash = "sha256-6jekESpsV6sDhBh23D7d5/BlGWI1G5SYgWudNvQKzqc=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    vala
    meson
    ninja
    pkg-config
    desktop-file-utils
    wrapGAppsHook4
    blueprint-compiler
  ];

  buildInputs = [
    gtk4
    glib
    gusb
    libadwaita
  ];

  mesonFlags = [
    (lib.mesonEnable "libportal" false)
  ];

  __structuredAttrs = true;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Client program for dumping over USB with nxdumptool";
    homepage = "https://github.com/v1993/nxdumpclient";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ ranidspace ];
    platforms = lib.platforms.linux;
    mainProgram = "nxdumpclient";
  };
})
