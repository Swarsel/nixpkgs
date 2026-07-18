{
  lib,
  fetchFromGitLab,
  appstream,
  blueprint-compiler,
  dbus,
  glib,
  gobject-introspection,
  libadwaita,
  meson,
  ninja,
  pandoc,
  pkg-config,
  python3Packages,
  wrapGAppsHook4,
  xdg-user-dirs,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "hydrapaper";
  version = "3.3.2";

  src = fetchFromGitLab {
    owner = "gabmus";
    repo = "HydraPaper";
    rev = finalAttrs.version;
    hash = "sha256-IDaM8bM/0KH9h59523WqLKe400V5lLNyJ4faPf980Ro=";
  };

  # wrapGAppsHook4 propagates gtk4 -- which provides gtk4-update-icon-cache instead
  postPatch = ''
    substituteInPlace meson_post_install.py \
      --replace-fail gtk-update-icon-cache gtk4-update-icon-cache
  '';

  nativeBuildInputs = [
    meson
    ninja
    glib
    pkg-config
    pandoc
    appstream
    blueprint-compiler
    gobject-introspection
    wrapGAppsHook4
  ];

  buildInputs = [
    dbus
    glib
    libadwaita
  ];

  propagatedBuildInputs = with python3Packages; [
    dbus-python
    pygobject3
    pillow
  ];

  preFixup = ''
    gappsWrapperArgs+=(
      --prefix PATH : ${
        lib.makeBinPath [
          glib
          xdg-user-dirs
        ]
      }
    )
    makeWrapperArgs+=("''${gappsWrapperArgs[@]}")
  '';

  dontWrapGApps = true;
  pyproject = false;

  meta = {
    description = "GNOME utility for setting different wallpapers on individual monitors";
    homepage = "https://hydrapaper.gabmus.org";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ lachrymal ];
    platforms = lib.platforms.linux;
    mainProgram = "hydrapaper";
  };
})
