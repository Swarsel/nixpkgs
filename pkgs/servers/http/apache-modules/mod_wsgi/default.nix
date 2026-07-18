{
  lib,
  stdenv,
  fetchFromGitHub,
  apacheHttpd,
  ncurses,
  python3,
}:

stdenv.mkDerivation rec {
  pname = "mod_wsgi";
  version = "5.0.2";

  src = fetchFromGitHub {
    owner = "GrahamDumpleton";
    repo = "mod_wsgi";
    rev = version;
    hash = "sha256-FhOSU8/4QoWa73bNi/qkgKm3CeEEdboh2MgxgQxcYzE=";
  };

  postPatch = ''
    substituteInPlace configure --replace '/usr/bin/lipo' 'lipo'
  '';

  buildInputs = [
    apacheHttpd
    python3
    ncurses
  ];

  makeFlags = [
    "LIBEXECDIR=$(out)/modules"
  ];

  meta = {
    description = "Host Python applications in Apache through the WSGI interface";
    homepage = "https://github.com/GrahamDumpleton/mod_wsgi";
    license = lib.licenses.asl20;
    platforms = lib.platforms.unix;
  };
}
