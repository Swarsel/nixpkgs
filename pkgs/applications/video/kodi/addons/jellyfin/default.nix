{
  lib,
  fetchFromGitHub,
  addonDir,
  buildKodiAddon,
  dateutil,
  kodi,
  kodi-six,
  requests,
  signals,
  six,
  websocket,
}:
let
  python = kodi.pythonPackages.python.withPackages (p: with p; [ pyyaml ]);
in
buildKodiAddon rec {
  pname = "jellyfin";
  version = "2.1.0";

  src = fetchFromGitHub {
    owner = "jellyfin";
    repo = "jellyfin-kodi";
    rev = "v${version}";
    sha256 = "sha256-S5LAIeYwApyGPsj999rotFgfAZmLxnJjuJD8CE4QDro=";
  };

  # ZIP does not support timestamps before 1980 - https://bugs.python.org/issue34097
  patches = [ ./no-strict-zip-timestamp.patch ];
  nativeBuildInputs = [ python ];

  propagatedBuildInputs = [
    requests
    dateutil
    six
    kodi-six
    signals
    websocket
  ];

  buildPhase = ''
    ${python}/bin/python3 build.py --version=py3
  '';

  postInstall = ''
    cp -v addon.xml $out${addonDir}/$namespace/
  '';

  namespace = "plugin.video.jellyfin";

  meta = {
    description = "Whole new way to manage and view your media library";
    homepage = "https://jellyfin.org/";
    license = lib.licenses.gpl3Only;
    teams = [ lib.teams.kodi ];
  };
}
