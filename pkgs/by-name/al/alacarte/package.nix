{
  lib,
  fetchFromGitLab,
  autoconf,
  automake,
  docbook_xsl,
  gettext,
  glib,
  gnome-menus,
  gobject-introspection,
  gtk3,
  libxslt,
  nix-update-script,
  pkg-config,
  python3,
  wrapGAppsHook3,
}:
python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "alacarte";
  version = "3.58.0";

  src = fetchFromGitLab {
    owner = "GNOME";
    repo = "alacarte";
    tag = finalAttrs.version;
    hash = "sha256-U3shnQ1GlDvOQFfjYVfAhCVRVQpTyLwEzHqKIbBChas=";
    domain = "gitlab.gnome.org";
  };

  nativeBuildInputs = [
    autoconf
    automake
    gettext
    pkg-config
    python3
    libxslt
    gobject-introspection
    wrapGAppsHook3
  ];

  buildInputs = [
    gnome-menus
    glib
    gtk3
  ];

  propagatedBuildInputs = with python3.pkgs; [ pygobject3 ];

  # Builder couldn't fetch the docbook.xsl from the internet directly,
  # so we substitute it with the docbook.xsl in already in nixpkgs
  preConfigure = ''
    substituteInPlace man/Makefile.am \
      --replace-fail "http://docbook.sourceforge.net/release/xsl/current/manpages/docbook.xsl" "${docbook_xsl}/xml/xsl/docbook/manpages/docbook.xsl"
  '';

  configureScript = "./autogen.sh";
  pyproject = false;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Menu editor for GNOME using the freedesktop.org menu specification";
    homepage = "https://gitlab.gnome.org/GNOME/alacarte";
    changelog = "https://gitlab.gnome.org/GNOME/alacarte/-/blob/${finalAttrs.version}/NEWS?ref_type=tags";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ pluiedev ];
    platforms = lib.platforms.linux;
    mainProgram = "alacarte";
  };
})
