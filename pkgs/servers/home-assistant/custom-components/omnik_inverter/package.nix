{
  lib,
  fetchFromGitHub,
  buildHomeAssistantComponent,
  omnikinverter,
}:

buildHomeAssistantComponent rec {
  version = "3.0.0";

  src = fetchFromGitHub {
    owner = "robbinjanssen";
    repo = "home-assistant-omnik-inverter";
    tag = version;
    hash = "sha256-L9us48J8fpIK3QHeEe3VhIAYBXbYegWYDi7OjeUollU=";
  };

  doCheck = false; # no tests

  dependencies = [
    omnikinverter
  ];

  domain = "omnik_inverter";
  owner = "robbinjanssen";

  meta = {
    description = "Omnik Inverter integration will scrape data from an Omnik inverter connected to your local network";
    homepage = "https://github.com/robbinjanssen/home-assistant-omnik-inverter";
    changelog = "https://github.com/robbinjanssen/home-assistant-omnik-inverter/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ _9R ];
  };
}
