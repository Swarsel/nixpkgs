{
  lib,
  stdenv,
  fetchurl,
  directoryListingUpdater,
  efl,
  meson,
  ninja,
  nixosTests,
  pkg-config,
  python3,
}:

stdenv.mkDerivation rec {
  pname = "terminology";
  version = "1.14.0";

  src = fetchurl {
    url = "https://download.enlightenment.org/rel/apps/${pname}/${pname}-${version}.tar.xz";
    sha256 = "81QFcFGwXP+2meM4NqETXbHU7Yv5VPm1fcDpO8MHUU0=";
  };

  postPatch = ''
    patchShebangs data/colorschemes/*.py
  '';

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    python3
  ];

  buildInputs = [
    efl
  ];

  passthru.tests.test = nixosTests.terminal-emulators.terminology;
  passthru.updateScript = directoryListingUpdater { };

  meta = {
    description = "Powerful terminal emulator based on EFL";
    homepage = "https://www.enlightenment.org/about-terminology";
    license = lib.licenses.bsd2;

    maintainers = with lib.maintainers; [
      matejc
    ];

    platforms = lib.platforms.linux;
    teams = [ lib.teams.enlightenment ];
  };
}
