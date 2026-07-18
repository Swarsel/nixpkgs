{
  lib,
  fetchFromGitLab,
  appstream,
  blueprint-compiler,
  gdk-pixbuf,
  glib-networking,
  gobject-introspection,
  gtk4,
  gtksourceview5,
  libadwaita,
  meson,
  ninja,
  pkg-config,
  python3,
  webkitgtk_4_1,
  wrapGAppsHook4,
}:
python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "giara";
  version = "1.1.0";

  src = fetchFromGitLab {
    owner = "World";
    repo = "giara";
    rev = finalAttrs.version;
    hash = "sha256-FTy0ElcoTGXG9eV85pUrF35qKDKOfYIovPtjLfTJVOg=";
    domain = "gitlab.gnome.org";
  };

  postPatch = ''
    substituteInPlace meson_post_install.py \
      --replace "gtk-update-icon-cache" "gtk4-update-icon-cache"
    # blueprint-compiler expects "profile" to be a string.
    substituteInPlace data/ui/headerbar.blp \
      --replace "item { custom: profile; }" 'item { custom: "profile"; }'
  '';

  nativeBuildInputs = [
    appstream
    meson
    gobject-introspection
    pkg-config
    ninja
    wrapGAppsHook4
    blueprint-compiler
  ];

  buildInputs = [
    gtk4
    gdk-pixbuf
    webkitgtk_4_1
    gtksourceview5
    glib-networking
    libadwaita
  ];

  pyproject = false;

  pythonPath = with python3.pkgs; [
    pygobject3
    pycairo
    python-dateutil
    praw
    pillow
    mistune
    beautifulsoup4
  ];

  meta = {
    description = "Reddit app, built with Python, GTK and Handy; Created with mobile Linux in mind";
    homepage = "https://gitlab.gnome.org/World/giara";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ dasj19 ];
    platforms = lib.platforms.linux;
    mainProgram = "giara";
  };
})
