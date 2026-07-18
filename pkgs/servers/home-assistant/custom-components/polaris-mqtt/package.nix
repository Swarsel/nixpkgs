{
  lib,
  fetchFromGitHub,
  buildHomeAssistantComponent,
}:

buildHomeAssistantComponent rec {
  version = "1.1.5";

  src = fetchFromGitHub {
    owner = "samoswall";
    repo = "polaris-mqtt";
    tag = "v${version}";
    hash = "sha256-NViyBWTN18DQV3WywD6AXdoOw6W+PgMIV5tuKyRgN2w=";
  };

  domain = "polaris";
  owner = "samoswall";

  meta = {
    description = "Polaris IQ Home devices integration to Home Assistant";
    homepage = "https://github.com/samoswall/polaris-mqtt";
    license = lib.licenses.gpl3Only;
    maintainers = [ lib.maintainers.k900 ];
  };
}
