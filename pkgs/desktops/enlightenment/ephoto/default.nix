{
  lib,
  stdenv,
  fetchurl,
  directoryListingUpdater,
  efl,
  meson,
  ninja,
  pkg-config,
}:

stdenv.mkDerivation rec {
  pname = "ephoto";
  version = "1.6.0";

  src = fetchurl {
    url = "https://download.enlightenment.org/rel/apps/${pname}/${pname}-${version}.tar.xz";
    sha256 = "1lvhcs4ba8h3z78nyycbww8mj4cscb8k200dcc3cdy8vrvrp7g1n";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
  ];

  buildInputs = [
    efl
  ];

  passthru.updateScript = directoryListingUpdater { };

  meta = {
    description = "Image viewer and editor written using the Enlightenment Foundation Libraries";
    homepage = "https://www.smhouston.us/ephoto/";
    license = lib.licenses.bsd2;
    platforms = lib.platforms.linux;
    mainProgram = "ephoto";
    teams = [ lib.teams.enlightenment ];
  };
}
