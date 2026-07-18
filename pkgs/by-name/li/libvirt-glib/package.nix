{
  lib,
  stdenv,
  fetchurl,
  buildPackages,
  docbook-xsl-nons,
  fetchpatch,
  gettext,
  gobject-introspection,
  gtk-doc,
  libcap_ng,
  libvirt,
  libxml2,
  meson,
  ninja,
  pkg-config,
  vala,
  withDocs ? stdenv.hostPlatform == stdenv.buildPlatform,
  withIntrospection ?
    lib.meta.availableOn stdenv.hostPlatform gobject-introspection
    && stdenv.hostPlatform.emulatorAvailable buildPackages,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libvirt-glib";
  version = "5.0.0";

  src = fetchurl {
    url = "https://libvirt.org/sources/glib/libvirt-glib-${finalAttrs.version}.tar.xz";
    sha256 = "m/7DRjgkFqNXXYcpm8ZBsqRkqlGf2bEofjGKpDovO4s=";
  };

  outputs = [
    "out"
    "dev"
  ]
  ++ lib.optional withDocs "devdoc";

  patches = [
    (fetchpatch {
      hash = "sha256-6mvINDd1HYS7oZsyNiyEwdNJfK5I5nPx86TRMq2RevA=";
      name = "relax-max-stack-size-limit.patch";
      url = "https://gitlab.com/libvirt/libvirt-glib/-/commit/062f21ccaa810087637ae24e0eb69f1a0f0a45f5.patch";
    })
  ];

  strictDeps = true;

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    gettext
    vala
    gobject-introspection
  ]
  ++ lib.optionals withIntrospection [
    gobject-introspection
  ]
  ++ lib.optionals withDocs [
    gtk-doc
    docbook-xsl-nons
  ];

  buildInputs = [
    libvirt
    libxml2
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    libcap_ng
  ];

  # The build system won't let us build with docs or introspection
  # unless we're building natively, but will still do a mandatory
  # check for the dependencies for those things unless we explicitly
  # disable the options.
  mesonFlags = [
    (lib.mesonEnable "docs" withDocs)
    (lib.mesonEnable "introspection" withIntrospection)
  ];

  meta = {
    description = "Wrapper library of libvirt for glib-based applications";

    longDescription = ''
      libvirt-glib wraps libvirt to provide a high-level object-oriented API better
      suited for glib-based applications, via three libraries:

      - libvirt-glib    - GLib main loop integration & misc helper APIs
      - libvirt-gconfig - GObjects for manipulating libvirt XML documents
      - libvirt-gobject - GObjects for managing libvirt objects
    '';

    homepage = "https://libvirt.org/";
    license = lib.licenses.lgpl2Plus;
    platforms = lib.platforms.unix;
  };
})
