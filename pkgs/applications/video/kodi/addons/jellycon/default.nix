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
  pname = "jellycon";
  version = "1.0.2";

  src = fetchFromGitHub {
    owner = "jellyfin";
    repo = "jellycon";
    rev = "v${version}";
    sha256 = "sha256-dpH611GZ+BG63bSFypcZ9VUtNCA/tL8zgKuaU7cCRII=";
  };

  nativeBuildInputs = [
    python
  ];

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

  namespace = "plugin.video.jellycon";

  prePatch = ''
    # ZIP does not support timestamps before 1980 - https://bugs.python.org/issue34097
    substituteInPlace build.py \
      --replace "with zipfile.ZipFile(f'{target}/{archive_name}', 'w') as z:" "with zipfile.ZipFile(f'{target}/{archive_name}', 'w', strict_timestamps=False) as z:"
  '';

  meta = {
    description = "Lightweight Kodi add-on for Jellyfin";

    longDescription = ''
      JellyCon is a lightweight Kodi add-on that lets you browse and play media
      files directly from your Jellyfin server within the Kodi interface. It can
      easily switch between multiple user accounts at will.
    '';

    homepage = "https://github.com/jellyfin/jellycon";
    license = lib.licenses.gpl2Only;
    teams = [ lib.teams.kodi ];
  };
}
