{
  lib,
  fetchFromGitHub,
  appstream,
  blueprint-compiler,
  desktop-file-utils,
  libadwaita,
  libportal-gtk4,
  meson,
  ninja,
  nix-update-script,
  python3Packages,
  wrapGAppsHook4,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "addwater";
  version = "1.3";

  src = fetchFromGitHub {
    owner = "largestgithubuseronearth";
    repo = "addwater";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ynfBP3yFw4g8ebnKKyQDdmCB7APYVgvuedcu/x5lO9w=";
  };

  nativeBuildInputs = [
    blueprint-compiler
    desktop-file-utils
    meson
    ninja
    wrapGAppsHook4
    appstream
  ];

  buildInputs = [
    libadwaita
    libportal-gtk4
  ];

  propagatedBuildInputs = with python3Packages; [
    packaging
    pygobject3
    requests
  ];

  # built with meson, not a python format
  pyproject = false;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Installer for the fantastic GNOME for Firefox theme";
    homepage = "https://github.com/largestgithubuseronearth/addwater";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ thtrf ];
    platforms = lib.platforms.linux;
    mainProgram = "addwater";
  };
})
