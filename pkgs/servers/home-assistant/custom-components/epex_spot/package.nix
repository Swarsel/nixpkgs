{
  lib,
  fetchFromGitHub,
  beautifulsoup4,
  buildHomeAssistantComponent,
}:

buildHomeAssistantComponent rec {
  version = "4.1.0";

  src = fetchFromGitHub {
    owner = "mampfes";
    repo = "ha_epex_spot";
    tag = version;
    hash = "sha256-FLXvnKuo74nAGIo+6dbn1/wzJCXWo+IltoXrxd4aEio=";
  };

  doCheck = false;

  dependencies = [
    beautifulsoup4
  ];

  domain = "epex_spot";
  #skip phases without activity
  dontConfigure = true;
  owner = "mampfes";

  meta = {
    description = "This component adds electricity prices from stock exchange EPEX Spot to Home Assistant";
    homepage = "https://github.com/mampfes/ha_epex_spot";
    changelog = "https://github.com/mampfes/ha_epex_spot/releases/tag/${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ _9R ];
  };
}
