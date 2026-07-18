{
  lib,
  stdenv,
  libxcrypt,
  perl,
  pkg-config,
  whois,
}:

stdenv.mkDerivation {
  inherit (whois) version src patches;
  inherit (whois) preConfigure;
  pname = "mkpasswd";

  outputs = [
    "out"
    "man"
  ];

  nativeBuildInputs = [
    perl
    pkg-config
  ];

  buildInputs = [ libxcrypt ];
  buildPhase = "make mkpasswd";
  installPhase = "make install-mkpasswd";

  meta = {
    description = "Overfeatured front-end to crypt, from the Debian whois package";
    homepage = "https://packages.qa.debian.org/w/whois.html";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ fpletz ];
    platforms = lib.platforms.unix;
    mainProgram = "mkpasswd";
  };
}
