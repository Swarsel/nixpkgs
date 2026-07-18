{
  lib,
  fetchFromGitHub,
  buildKodiAddon,
  infotagger,
  requests,
}:

buildKodiAddon rec {
  pname = "jurialmunkey";
  version = "0.2.35";

  src = fetchFromGitHub {
    owner = "jurialmunkey";
    repo = namespace;
    rev = "v${version}";
    hash = "sha256-3qcLh1vZ4Y7Sf5NHl4j6cmb+n6KodwOBjmBmHLDinCY=";
  };

  propagatedBuildInputs = [
    requests
    infotagger
  ];

  namespace = "script.module.jurialmunkey";

  passthru = {
    pythonPath = "resources/modules";
  };

  meta = {
    description = "Common code required by TMDbHelper and other related jurialmunkey add-ons";
    homepage = "https://github.com/jurialmunkey/script.module.jurialmunkey/tree/main";
    license = lib.licenses.gpl3Plus;
    teams = [ lib.teams.kodi ];
  };
}
