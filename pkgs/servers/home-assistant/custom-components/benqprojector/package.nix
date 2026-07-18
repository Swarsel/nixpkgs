{
  lib,
  fetchFromGitHub,
  benqprojector,
  buildHomeAssistantComponent,
}:

buildHomeAssistantComponent rec {
  version = "0.1.4";

  src = fetchFromGitHub {
    inherit owner;
    repo = "homeassistant-benqprojector";
    tag = version;
    hash = "sha256-BiAqEVZSbroxw46thsU1psjP9JEEZaGRLWgpT/lQTHI=";
  };

  dependencies = [ benqprojector ];
  domain = "benqprojector";
  owner = "rrooggiieerr";

  meta = rec {
    description = "Home Assistant integration for BenQ projectors";
    homepage = "https://github.com/rrooggiieerr/homeassistant-benqprojector";
    changelog = "${homepage}/releases/tag/${version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ sephalon ];
  };
}
