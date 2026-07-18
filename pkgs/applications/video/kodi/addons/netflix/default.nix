{
  lib,
  fetchFromGitHub,
  buildKodiAddon,
  inputstream-adaptive,
  inputstreamhelper,
  myconnpy,
  requests,
  signals,
}:

buildKodiAddon rec {
  pname = "netflix";
  version = "1.23.5";

  src = fetchFromGitHub {
    owner = "CastagnaIT";
    repo = namespace;
    rev = "v${version}";
    hash = "sha256-IIRut99AH08Z3udTkzUf2wz7dQMA94dOnfROm7iM9RM=";
  };

  propagatedBuildInputs = [
    signals
    inputstream-adaptive
    inputstreamhelper
    requests
    myconnpy
  ];

  namespace = "plugin.video.netflix";

  meta = {
    description = "Netflix VOD Services Add-on";
    homepage = "https://github.com/CastagnaIT/plugin.video.netflix";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.pks ];
    teams = [ lib.teams.kodi ];
  };
}
