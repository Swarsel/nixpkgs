{
  lib,
  stdenv,
  fetchurl,
  gtk3,
  ibus,
  libthai,
  pkg-config,
}:

stdenv.mkDerivation rec {
  pname = "ibus-libthai";
  version = "0.1.5";

  src = fetchurl {
    url = "https://linux.thai.net/pub/ThaiLinux/software/libthai/ibus-libthai-${version}.tar.xz";
    sha256 = "sha256-egAxttjwuKiDoIuJluoOTJdotFZJe6ZOmJgdiFCAwx0=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    gtk3
    ibus
    libthai
  ];

  meta = {
    description = "Thai input method engine for IBus";
    homepage = "https://linux.thai.net/projects/ibus-libthai";
    license = lib.licenses.lgpl21Plus;
    maintainers = [ ];
    platforms = lib.platforms.unix;
    isIbusEngine = true;
  };
}
