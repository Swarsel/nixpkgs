{
  lib,
  stdenv,
  fetchurl,
  intltool,
  libotr,
  pidgin,
}:

stdenv.mkDerivation rec {
  pname = "pidgin-otr";
  version = "4.0.2";

  src = fetchurl {
    url = "https://otr.cypherpunks.ca/pidgin-otr-${version}.tar.gz";
    sha256 = "1i5s9rrgbyss9rszq6c6y53hwqyw1k86s40cpsfx5ccl9bprxdgl";
  };

  nativeBuildInputs = [ intltool ];

  buildInputs = [
    libotr
    pidgin
  ];

  postInstall = "ln -s \$out/lib/pidgin \$out/share/pidgin-otr";

  meta = {
    description = "Plugin for Pidgin 2.x which implements OTR Messaging";
    homepage = "https://otr.cypherpunks.ca/";
    license = lib.licenses.gpl2;
    maintainers = [ ];
    platforms = lib.platforms.linux;
  };
}
