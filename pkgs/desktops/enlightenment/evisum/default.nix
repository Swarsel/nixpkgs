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
  pname = "evisum";
  version = "2.0.12";

  src = fetchurl {
    url = "https://download.enlightenment.org/rel/apps/${pname}/${pname}-${version}.tar.xz";
    sha256 = "I0h2g8+y5MrYfkgbL5iI+CegvU2UgF0KoArOHu611lQ=";
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
    description = "System and process monitor written with EFL";
    homepage = "https://git.enlightenment.org/enlightenment/evisum";
    license = with lib.licenses; [ isc ];
    platforms = lib.platforms.linux;
    mainProgram = "evisum";
    teams = [ lib.teams.enlightenment ];
  };
}
