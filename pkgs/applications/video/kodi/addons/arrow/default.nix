{
  lib,
  addonUpdateScript,
  buildKodiAddon,
  dateutil,
  fetchzip,
  rel,
  typing_extensions,
}:
buildKodiAddon rec {
  pname = "arrow";
  version = "1.2.3";

  src = fetchzip {
    url = "https://mirrors.kodi.tv/addons/${lib.toLower rel}/script.module.arrow/script.module.arrow-${version}.zip";
    sha256 = "sha256-Et+9FJT1dRE1dFOrAQ70HJJcfylyLsiyay9wPJcSOXs=";
  };

  propagatedBuildInputs = [
    dateutil
    typing_extensions
  ];

  namespace = "script.module.arrow";

  passthru = {
    pythonPath = "lib";

    updateScript = addonUpdateScript {
      attrPath = "kodi.packages.arrow";
    };
  };

  meta = {
    description = "Better dates & times for Python";
    homepage = "https://github.com/razzeee/script.module.arrow";
    license = lib.licenses.asl20;
    teams = [ lib.teams.kodi ];
  };
}
