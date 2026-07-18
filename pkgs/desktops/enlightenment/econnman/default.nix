{
  lib,
  stdenv,
  fetchurl,
  dbus,
  directoryListingUpdater,
  efl,
  makeWrapper,
  pkg-config,
  python3Packages,
}:

stdenv.mkDerivation rec {
  pname = "econnman";
  version = "1.1";

  src = fetchurl {
    url = "http://download.enlightenment.org/rel/apps/econnman/${pname}-${version}.tar.xz";
    sha256 = "sha256-DM6HaB+ufKcPHmPP4K5l/fF7wzRycFQxfiXjiXYZ7YU=";
  };

  nativeBuildInputs = [
    makeWrapper
    pkg-config
    python3Packages.wrapPython
  ];

  buildInputs = [
    dbus
    efl
    python3Packages.python
  ];

  postInstall = ''
    wrapPythonPrograms
  '';

  pythonPath = [
    python3Packages.dbus-python
    python3Packages.pythonefl
  ];

  passthru.updateScript = directoryListingUpdater { };

  meta = {
    description = "User interface for the connman network connection manager";
    homepage = "https://enlightenment.org/";
    license = lib.licenses.lgpl3;

    maintainers = with lib.maintainers; [
      matejc
    ];

    platforms = lib.platforms.linux;
    mainProgram = "econnman-bin";
    teams = [ lib.teams.enlightenment ];
  };
}
