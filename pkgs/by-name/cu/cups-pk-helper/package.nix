{
  lib,
  stdenv,
  fetchurl,
  cups,
  fetchpatch,
  glib,
  intltool,
  pkg-config,
  polkit,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "cups-pk-helper";
  version = "0.2.6";

  src = fetchurl {
    url = "https://www.freedesktop.org/software/cups-pk-helper/releases/cups-pk-helper-${finalAttrs.version}.tar.xz";
    sha256 = "0a52jw6rm7lr5nbyksiia0rn7sasyb5cjqcb95z1wxm2yprgi6lm";
  };

  patches = [
    # Don't use etc/dbus-1/system.d
    (fetchpatch {
      sha256 = "1kamhr5kn8c1y0q8xbip0fgr7maf3dyddlvab4n0iypk7rwwikl0";
      url = "https://gitlab.freedesktop.org/cups-pk-helper/cups-pk-helper/merge_requests/2.patch";
    })
  ];

  nativeBuildInputs = [
    pkg-config
    intltool
  ];

  buildInputs = [
    glib
    polkit
    cups
  ];

  meta = {
    description = "PolicyKit helper to configure cups with fine-grained privileges";
    homepage = "https://www.freedesktop.org/wiki/Software/cups-pk-helper/";
    license = lib.licenses.gpl2Plus;
    maintainers = [ lib.maintainers.bjornfor ];
    platforms = lib.platforms.linux;
  };
})
