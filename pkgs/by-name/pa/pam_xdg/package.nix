{
  lib,
  stdenv,
  fetchurl,
  coreutils,
  pam,
}:
stdenv.mkDerivation rec {
  pname = "pam_xdg";
  version = "0.8.5";

  src = fetchurl {
    url = "https://ftp.sdaoden.eu/pam_xdg-${version}.tar.gz";
    sha256 = "sha256-o4Fol6LouBQVLiGMAszEB+zBkBj8C1xMp057AvH3nl4=";
  };

  postPatch = ''
    substituteInPlace pam_xdg.c \
      --replace-fail '"/usr/bin/rm"' '"${coreutils}/bin/rm"'
  '';

  buildInputs = [
    pam
  ];

  makeFlags = [
    "PREFIX=$(out)"
  ];

  meta = {
    description = "PAM module that manages XDG Base Directories";
    homepage = "https://www.sdaoden.eu/code-pam_xdg.html";
    license = lib.licenses.isc;
    maintainers = with lib; [ maintainers.aanderse ];
    platforms = lib.platforms.unix;
  };
}
