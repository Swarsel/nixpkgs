{
  lib,
  fetchFromGitHub,
  aioairctrl,
  buildHomeAssistantComponent,
  getmac,
}:

buildHomeAssistantComponent rec {
  version = "0.36.2";

  src = fetchFromGitHub {
    inherit owner;
    repo = "philips-airpurifier-coap";
    rev = "v${version}";
    hash = "sha256-aVCfUuwPW+0L+OuOoLV0cPezZVKHtO39p/TK/gy2jdg=";
  };

  dependencies = [
    aioairctrl
    getmac
  ];

  domain = "philips_airpurifier_coap";

  ignoreVersionRequirement = [
    "getmac"
  ];

  owner = "kongo09";

  meta = {
    description = "Philips AirPurifier custom component for Home Assistant";
    homepage = "https://github.com/kongo09/philips-airpurifier-coap";
    license = lib.licenses.unfree; # See https://github.com/kongo09/philips-airpurifier-coap/issues/209
    maintainers = with lib.maintainers; [ justinas ];
  };
}
