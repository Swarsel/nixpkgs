{
  lib,
  stdenv,
  fetchurl,
  check,
  curl,
  docbook_xsl,
  fetchpatch,
  gettext,
  glib,
  gobject-introspection,
  gtk-doc,
  hwdata,
  libsoup_3,
  libxml2,
  libxslt,
  meson,
  ninja,
  osinfo-db,
  perl,
  pkg-config,
  replaceVars,
  vala ? null,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libosinfo";
  version = "1.12.0";

  src = fetchurl {
    url = "https://releases.pagure.org/libosinfo/libosinfo-${finalAttrs.version}.tar.xz";
    sha256 = "sha256-rYVX7OJnk9pD0m3lZePWjOLua/uNARO3zH3+B/a/xrY=";
  };

  outputs = [
    "out"
    "dev"
  ]
  ++ lib.optional (stdenv.hostPlatform == stdenv.buildPlatform) "devdoc";

  patches = [
    (replaceVars ./osinfo-db-data-dir.patch {
      osinfo_db_data_dir = "${osinfo-db}/share";
    })

    # Fix build with libxml 2.14
    (fetchpatch {
      hash = "sha256-NZija5BwevRU7bAe2SPx9GnoGb1P+mXEbJ5EVAFT9Yw=";
      url = "https://gitlab.com/libosinfo/libosinfo/-/commit/0adf38535637ec668e658d43f04f60f11f51574f.patch";
    })
  ];

  nativeBuildInputs = [
    pkg-config
    meson
    ninja
    vala
    gettext
    gobject-introspection
    gtk-doc
    docbook_xsl
    perl # for pod2man
  ];

  buildInputs = [
    glib
    libsoup_3
    libxml2
    libxslt
  ];

  mesonFlags = [
    "-Dwith-usb-ids-path=${hwdata}/share/hwdata/usb.ids"
    "-Dwith-pci-ids-path=${hwdata}/share/hwdata/pci.ids"
    "-Denable-gtk-doc=true"
  ];

  doCheck = true;

  nativeCheckInputs = [
    check
    curl
    perl
  ];

  preCheck = ''
    patchShebangs ../osinfo/check-symfile.pl ../osinfo/check-symsorting.pl
  '';

  meta = {
    description = "GObject based library API for managing information about operating systems, hypervisors and the (virtual) hardware devices they can support";
    homepage = "https://libosinfo.org/";
    changelog = "https://gitlab.com/libosinfo/libosinfo/-/blob/v${finalAttrs.version}/NEWS";
    license = lib.licenses.lgpl2Plus;
    maintainers = [ lib.maintainers.bjornfor ];
    platforms = lib.platforms.unix;
  };
})
