{
  lib,
  fetchFromGitHub,
  addonDir,
  addonUpdateScript,
  buildKodiAddon,
  kodi-six,
  requests,
  six,
}:

buildKodiAddon rec {
  pname = "plex";
  version = "0.7.9-rev4";

  src = fetchFromGitHub {
    owner = "pannal";
    repo = "plex-for-kodi";
    rev = "v${version}";
    sha256 = "sha256-rNxTz3SKHHBm0WDCoZ/foJN2pBBiyI3a/tOdQdOCuXA=";
  };

  # Plex for Kodi writes to its own directory by default, needs to be patched to a non-store path.
  # Once https://github.com/pannal/plex-for-kodi/pull/219 is merged, this can be replaced with a smaller patch that just sets the environment variable INSTALLATION_DIR_AVOID_WRITE, e.g. adding to main.py:
  # import os; os.environ("INSTALLATION_DIR_AVOID_WRITE") = True
  patches = [ ./plex-template-dir.patch ];

  propagatedBuildInputs = [
    six
    requests
    kodi-six
  ];

  postInstall = ''
    mv /build/source/addon.xml $out${addonDir}/${namespace}/
  '';

  namespace = "script.plex";

  passthru = {
    updateScript = addonUpdateScript {
      attrPath = "kodi.packages.plex";
    };
  };

  meta = {
    description = "Unofficial Plex for Kodi add-on";
    homepage = "https://www.plex.tv";
    license = lib.licenses.gpl2Only;
    maintainers = lib.teams.kodi.members;
  };
}
