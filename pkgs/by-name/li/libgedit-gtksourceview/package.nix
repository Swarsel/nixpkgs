{
  lib,
  stdenv,
  fetchFromGitLab,
  docbook-xsl-nons,
  gitUpdater,
  glib,
  gobject-introspection,
  gtk-doc,
  gtk3,
  libgedit-amtk,
  libgedit-gfls,
  libxml2,
  meson,
  ninja,
  pkg-config,
  shared-mime-info,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libgedit-gtksourceview";
  version = "299.7.1";

  src = fetchFromGitLab {
    owner = "gedit";
    repo = "libgedit-gtksourceview";
    tag = finalAttrs.version;
    hash = "sha256-i+6Rfqm/KPJrLSvhvTVY53Q6O+LJEU9WjLJ/L3hMSUA=";
    domain = "gitlab.gnome.org";
    forceFetchGit = true; # To avoid occasional 501 failures.
    group = "World";
  };

  outputs = [
    "out"
    "dev"
    "devdoc"
  ];

  patches = [
    # By default, the library loads syntaxes from XDG_DATA_DIRS and user directory
    # but not from its own datadr (it assumes it will be in XDG_DATA_DIRS).
    # Since this is not generally true with Nix, let’s add $out/share unconditionally.
    ./nix-share-path.patch
  ];

  nativeBuildInputs = [
    docbook-xsl-nons
    gobject-introspection
    gtk-doc
    meson
    ninja
    pkg-config
  ];

  buildInputs = [
    libgedit-amtk
    libgedit-gfls
    libxml2
  ];

  propagatedBuildInputs = [
    # Required by libgedit-gtksourceview-300.pc
    glib
    gtk3
    # Used by gtk_source_language_manager_guess_language
    shared-mime-info
  ];

  passthru.updateScript = gitUpdater { ignoredVersions = "(alpha|beta|rc).*"; };

  meta = {
    description = "Source code editing widget for GTK";
    homepage = "https://gitlab.gnome.org/World/gedit/libgedit-gtksourceview";
    license = lib.licenses.lgpl21Plus;
    maintainers = with lib.maintainers; [ bobby285271 ];
    platforms = lib.platforms.linux;
  };
})
