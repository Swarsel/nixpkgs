{
  lib,
  stdenv,
  fetchFromGitLab,
  dconf,
  desktop-file-utils,
  docbook-xsl-nons,
  gettext,
  gitUpdater,
  glib,
  gobject-introspection,
  gsettings-desktop-schemas,
  gspell,
  gtk-doc,
  itstool,
  libgedit-amtk,
  libgedit-gtksourceview,
  libgedit-tepl,
  libgee,
  meson,
  ninja,
  pkg-config,
  vala,
  wrapGAppsHook3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "enter-tex";
  version = "3.49.0";

  src = fetchFromGitLab {
    owner = "gedit";
    repo = "enter-tex";
    tag = finalAttrs.version;
    hash = "sha256-CRxWN4eeB9uDdLtRh3aXHoN+gSlXSPDftGHcPtjgAzU=";
    domain = "gitlab.gnome.org";
    group = "World";
  };

  nativeBuildInputs = [
    desktop-file-utils
    docbook-xsl-nons
    gettext
    gobject-introspection
    gtk-doc
    itstool
    meson
    ninja
    pkg-config
    vala
    wrapGAppsHook3
  ];

  buildInputs = [
    dconf
    glib
    gsettings-desktop-schemas
    gspell
    libgedit-amtk
    libgedit-gtksourceview
    libgedit-tepl
    libgee
  ];

  preBuild = ''
    # Workaround the use case of C code mixed with Vala code.
    # https://gitlab.gnome.org/World/gedit/enter-tex/-/blob/3.48.0/docs/more-information.md#install-procedure
    ninja src/gtex/Gtex-1.gir
  '';

  doCheck = true;
  passthru.updateScript = gitUpdater { };

  meta = {
    description = "LaTeX editor for the GNOME desktop";
    homepage = "https://gitlab.gnome.org/World/gedit/enter-tex";
    license = lib.licenses.gpl3Plus;

    maintainers = with lib.maintainers; [
      bobby285271
    ];

    platforms = lib.platforms.linux;
    mainProgram = "enter-tex";
  };
})
