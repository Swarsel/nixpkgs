{
  lib,
  fetchFromGitLab,
  desktop-file-utils,
  gobject-introspection,
  gtk4,
  libadwaita,
  meson,
  ninja,
  pkg-config,
  python3,
  wrapGAppsHook4,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "powersupply";
  version = "0.10.2";

  src = fetchFromGitLab {
    owner = "postmarketOS";
    repo = "powersupply";
    rev = finalAttrs.version;
    hash = "sha256-i0AZfxYWj8ct2jiXl2GnCGMU3xBSRRny4H0G/5Qs14Y=";
    domain = "gitlab.postmarketos.org";
  };

  postPatch = ''
    substituteInPlace build-aux/meson/postinstall.py \
      --replace 'gtk-update-icon-cache' 'gtk4-update-icon-cache'
  '';

  strictDeps = true;

  nativeBuildInputs = [
    desktop-file-utils
    gtk4 # for gtk4-update-icon-cache
    gobject-introspection # Without this, launching the app on aarch64-linux results in ValueError: Namespace Gtk not available
    meson
    ninja
    pkg-config
    wrapGAppsHook4
  ];

  buildInputs = [
    gtk4
    libadwaita
  ];

  dependencies = with python3.pkgs; [
    pygobject3
  ];

  pyproject = false;

  meta = {
    description = "Graphical app to display power status of mobile Linux platforms";
    homepage = "https://gitlab.postmarketos.org/postmarketOS/powersupply";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ Luflosi ];
    platforms = lib.platforms.linux;
    mainProgram = "powersupply";
  };
})
