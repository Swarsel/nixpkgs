# Needed for apps that still depend on the unstable version of the library (not libhandy-1)
{
  lib,
  stdenv,
  fetchFromGitLab,
  dbus,
  docbook_xml_dtd_43,
  docbook_xsl,
  gnome-desktop,
  gobject-introspection,
  gtk-doc,
  gtk3,
  hicolor-icon-theme,
  libxml2,
  meson,
  ninja,
  pkg-config,
  vala,
  xvfb-run,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libhandy";
  version = "0.0.13";

  src = fetchFromGitLab {
    owner = "Librem5";
    repo = "libhandy";
    rev = "v${finalAttrs.version}";
    sha256 = "1y23k623sjkldfrdiwfarpchg5mg58smcy1pkgnwfwca15wm1ra5";
    domain = "source.puri.sm";
  };

  outputs = [
    "out"
    "dev"
    "devdoc"
  ];

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    gobject-introspection
    vala
    libxml2
    gtk-doc
    docbook_xsl
    docbook_xml_dtd_43
  ];

  buildInputs = [
    gnome-desktop
    gtk3
    libxml2
  ];

  mesonFlags = [
    "-Dgtk_doc=true"
    "-Dglade_catalog=disabled"
    "-Dintrospection=enabled"
  ];

  doCheck = !stdenv.hostPlatform.isDarwin;

  nativeCheckInputs = [
    dbus
    xvfb-run
    hicolor-icon-theme
  ];

  checkPhase = ''
    NO_AT_BRIDGE=1 \
    XDG_DATA_DIRS="$XDG_DATA_DIRS:${hicolor-icon-theme}/share" \
    xvfb-run -s '-screen 0 800x600x24' dbus-run-session \
      --config-file=${dbus}/share/dbus-1/session.conf \
      meson test --print-errorlogs
  '';

  outputBin = "dev";

  meta = {
    description = "Library full of GTK widgets for mobile phones";
    homepage = "https://source.puri.sm/Librem5/libhandy";
    license = lib.licenses.lgpl21Plus;
    maintainers = [ ];
    platforms = lib.platforms.unix;
    mainProgram = "handy-0.0-demo";
  };
})
