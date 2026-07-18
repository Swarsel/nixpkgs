{
  lib,
  stdenv,
  fetchurl,
  dbus,
  dbus-glib,
  glib,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "eggdbus";
  version = "0.6";

  src = fetchurl {
    url = "https://hal.freedesktop.org/releases/eggdbus-${finalAttrs.version}.tar.gz";
    sha256 = "118hj63ac65zlg71kydv4607qcg1qpdlql4kvhnwnnhar421jnq4";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    glib
    dbus
    dbus-glib
  ];

  meta = {
    description = "D-Bus bindings for GObject";
    homepage = "https://hal.freedesktop.org/releases/";
    license = lib.licenses.lgpl2;
    platforms = lib.platforms.linux;
  };
})
