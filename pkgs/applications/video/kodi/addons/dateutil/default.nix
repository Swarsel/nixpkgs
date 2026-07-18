{
  lib,
  addonUpdateScript,
  buildKodiAddon,
  fetchzip,
  rel,
  six,
}:

buildKodiAddon rec {
  pname = "dateutil";
  version = "2.8.2";

  src = fetchzip {
    url = "https://mirrors.kodi.tv/addons/${lib.toLower rel}/${namespace}/${namespace}-${version}.zip";
    sha256 = "sha256-iQnyS0GjYcPbnBDUxmMrmDxHOA3K8RbTVke/HF4d5u4=";
  };

  propagatedBuildInputs = [
    six
  ];

  namespace = "script.module.dateutil";

  passthru = {
    pythonPath = "lib";

    updateScript = addonUpdateScript {
      attrPath = "kodi.packages.dateutil";
    };
  };

  meta = {
    description = "Extensions to the standard Python datetime module";
    homepage = "https://dateutil.readthedocs.io/en/stable/";

    license = with lib.licenses; [
      asl20
      bsd3
    ];

    teams = [ lib.teams.kodi ];
  };
}
