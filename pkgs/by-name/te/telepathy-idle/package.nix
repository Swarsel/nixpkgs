{
  lib,
  stdenv,
  fetchurl,
  dbus-glib,
  dconf,
  glib,
  glib-networking,
  libxslt,
  makeWrapper,
  pkg-config,
  python3,
  telepathy-glib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "telepathy-idle";
  version = "0.2.2";

  src = fetchurl {
    url = "https://telepathy.freedesktop.org/releases/telepathy-idle/telepathy-idle-${finalAttrs.version}.tar.gz";
    hash = "sha256-g4fiXl+wtMvnAeXcCS1mbWUQuDP9Pn5GLpFw027DwV8=";
  };

  nativeBuildInputs = [
    pkg-config
    python3
    makeWrapper
  ];

  buildInputs = [
    glib
    glib-networking
    telepathy-glib
    dbus-glib
    libxslt
    (lib.getLib dconf)
  ];

  preFixup = ''
    wrapProgram "$out/libexec/telepathy-idle" \
      --prefix GIO_EXTRA_MODULES : "${
        lib.makeSearchPath "lib/gio/modules" [
          (lib.getLib dconf)
          glib-networking
        ]
      }"
  '';

  meta = {
    description = "IRC connection manager for the Telepathy framework";
    homepage = "https://telepathy.freedesktop.org/components/telepathy-idle/";
    license = lib.licenses.lgpl21Plus;
    platforms = lib.platforms.unix;
  };
})
