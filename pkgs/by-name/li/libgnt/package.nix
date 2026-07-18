{
  lib,
  stdenv,
  fetchurl,
  docbook-xsl-nons,
  glib,
  gtk-doc,
  libxml2,
  meson,
  mesonEmulatorHook,
  ncurses,
  ninja,
  pkg-config,
  buildDocs ? true,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "libgnt";
  version = "2.14.4-dev";

  src = fetchurl {
    url = "mirror://sourceforge/pidgin/libgnt-${finalAttrs.version}.tar.xz";
    hash = "sha256-GVkzqacx01dXkbiBulzArSpxXh6cTCPMqqKhfhZMluw=";
  };

  outputs = [
    "out"
    "dev"
  ]
  ++ lib.optional buildDocs "devdoc";

  postPatch = ''
    substituteInPlace meson.build --replace-fail \
      "ncurses_sys_prefix = '/usr'" \
      "ncurses_sys_prefix = '${lib.getDev ncurses}'"
  '';

  nativeBuildInputs = [
    glib
    meson
    ninja
    pkg-config
  ]
  ++ lib.optionals buildDocs [
    gtk-doc
    docbook-xsl-nons
  ]
  ++ lib.optionals (buildDocs && !stdenv.buildPlatform.canExecute stdenv.hostPlatform) [
    mesonEmulatorHook
  ];

  buildInputs = [
    glib
    ncurses
    libxml2
  ];

  mesonFlags = [
    (lib.mesonBool "doc" buildDocs)
    (lib.mesonBool "python2" false)
  ];

  meta = {
    description = "Ncurses toolkit for creating text-mode graphical user interfaces";
    homepage = "https://keep.imfreedom.org/libgnt/libgnt/";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ ony ];
    platforms = lib.platforms.unix;
  };
})
