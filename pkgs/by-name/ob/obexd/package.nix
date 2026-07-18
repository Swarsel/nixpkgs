{
  lib,
  stdenv,
  fetchurl,
  bluez,
  dbus,
  glib,
  libical,
  openobex,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "obexd";
  version = "0.48";

  src = fetchurl {
    url = "mirror://kernel/linux/bluetooth/obexd-${finalAttrs.version}.tar.bz2";
    sha256 = "1i20dnibvnq9lnkkhajr5xx3kxlwf9q5c4jm19kyb0q1klzgzlb8";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    glib
    dbus
    openobex
    bluez
    libical
  ];

  meta = {
    homepage = "https://www.bluez.org/";
    license = lib.licenses.gpl3;
    platforms = lib.platforms.linux;
  };
})
