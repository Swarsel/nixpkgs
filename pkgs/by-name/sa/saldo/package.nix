{
  lib,
  fetchFromGitLab,
  appstream,
  blueprint-compiler,
  desktop-file-utils,
  gitUpdater,
  glib,
  gobject-introspection,
  gtk4,
  libadwaita,
  librsvg,
  libxml2,
  meson,
  ninja,
  pkg-config,
  python3,
  wrapGAppsHook4,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "saldo";
  version = "0.8.4";

  src = fetchFromGitLab {
    owner = "tabos";
    repo = "saldo";
    tag = finalAttrs.version;
    hash = "sha256-QOhHDbXq+QHq6XV/ejt5+Si1bXRZZxLjsRlWVw7Zsuk=";
  };

  postPatch = ''
    patchShebangs meson_post_conf.py meson_post_install.py
  '';

  nativeBuildInputs = [
    appstream # for appstreamcli
    blueprint-compiler
    desktop-file-utils # for desktop-file-validate
    glib # for glib-compile-resources
    libxml2 # for xmllint
    meson
    ninja
    pkg-config
    wrapGAppsHook4
    gobject-introspection
    gtk4 # for gtk4-update-icon-cache
  ];

  buildInputs = [
    libadwaita
    librsvg
  ];

  dependencies = with python3.pkgs; [
    cryptography
    fints
    mt-940
    onetimepad
    pygobject3
    schwifty
  ];

  pyproject = false;
  passthru.updateScript = gitUpdater { };

  meta = {
    description = "Banking application for small screens";
    homepage = "https://www.tabos.org/projects/saldo/";
    changelog = "https://gitlab.com/tabos/saldo/-/blob/${finalAttrs.src.tag}/NEWS";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ dotlambda ];
    mainProgram = "org.tabos.saldo";
  };
})
