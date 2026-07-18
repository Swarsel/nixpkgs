{
  lib,
  fetchFromGitHub,
  buildHomeAssistantComponent,
  dirigera,
}:

buildHomeAssistantComponent rec {
  version = "2.7.1";

  src = fetchFromGitHub {
    owner = "sanjoyg";
    repo = "dirigera_platform";
    tag = version;
    hash = "sha256-N4H07CmIEqUqv1VkLlL1f924TvZ4Cb4IuVKlRYJA9CM=";
  };

  postPatch = ''
    substituteInPlace custom_components/dirigera_platform/manifest.json \
      --replace-fail "0.0.1" "${version}"
  '';

  dependencies = [ dirigera ];
  domain = "dirigera_platform";
  ignoreVersionRequirement = [ "dirigera" ];
  owner = "sanjoyg";

  meta = {
    description = "Home-assistant integration for IKEA Dirigera hub";
    homepage = "https://github.com/sanjoyg/dirigera_platform";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ rhoriguchi ];
  };
}
