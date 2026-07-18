{
  lib,
  addonUpdateScript,
  buildKodiAddon,
  fetchzip,
  rel,
}:

buildKodiAddon rec {
  pname = "urllib3";
  version = "2.2.3";

  src = fetchzip {
    url = "https://mirrors.kodi.tv/addons/${lib.toLower rel}/${namespace}/${namespace}-${version}.zip";
    sha256 = "sha256-xapFA51ENjkB3IldUey5WqXAjMij66dNqILQjKD/VkA=";
  };

  namespace = "script.module.urllib3";

  passthru = {
    pythonPath = "lib";

    updateScript = addonUpdateScript {
      attrPath = "kodi.packages.urllib3";
    };
  };

  meta = {
    description = "HTTP library with thread-safe connection pooling, file post, and more";
    homepage = "https://urllib3.readthedocs.io/en/latest/";
    license = lib.licenses.mit;
    teams = [ lib.teams.kodi ];
  };
}
