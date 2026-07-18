{
  lib,
  stdenv,
  fetchurl,
  atk,
  autoreconfHook,
  bamf,
  cairo,
  dconf,
  file,
  gdk-pixbuf,
  gettext,
  glib,
  gnome-common,
  gnome-menus,
  gtk3,
  libdbusmenu-gtk3,
  libgee,
  libwnck,
  libx11,
  libxfixes,
  libxi,
  libxml2,
  pango,
  pkg-config,
  vala,
  wrapGAppsHook3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "plank";
  version = "0.11.89";

  src = fetchurl {
    url = "https://launchpad.net/plank/1.0/${finalAttrs.version}/+download/plank-${finalAttrs.version}.tar.xz";
    sha256 = "17cxlmy7n13jp1v8i4abxyx9hylzb39andhz3mk41ggzmrpa8qm6";
  };

  # Make plank's application launcher hidden in Pantheon
  patches = [
    ./hide-in-pantheon.patch
  ];

  postPatch = ''
    substituteInPlace ./configure \
      --replace "/usr/bin/file" "${file}/bin/file"
  '';

  nativeBuildInputs = [
    autoreconfHook
    gettext
    gnome-common
    libxml2 # xmllint
    pkg-config
    vala
    wrapGAppsHook3
  ];

  buildInputs = [
    atk
    bamf
    cairo
    gdk-pixbuf
    glib
    gnome-menus
    dconf
    gtk3
    libx11
    libxfixes
    libxi
    libdbusmenu-gtk3
    libgee
    libwnck
    pango
  ];

  # fix paths
  makeFlags = [
    "INTROSPECTION_GIRDIR=${placeholder "out"}/share/gir-1.0/"
    "INTROSPECTION_TYPELIBDIR=${placeholder "out"}/lib/girepository-1.0"
  ];

  meta = {
    description = "Elegant, simple, clean dock";
    homepage = "https://launchpad.net/plank";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ davidak ];
    platforms = lib.platforms.linux;
    mainProgram = "plank";
    teams = [ lib.teams.pantheon ];
  };
})
