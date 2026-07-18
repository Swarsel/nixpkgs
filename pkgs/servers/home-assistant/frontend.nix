{
  lib,
  buildPythonPackage,
  fetchPypi,
}:

buildPythonPackage (finalAttrs: {
  # the frontend version corresponding to a specific home-assistant version can be found here
  # https://github.com/home-assistant/home-assistant/blob/master/homeassistant/components/frontend/manifest.json
  pname = "home-assistant-frontend";
  version = "20260624.5";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-7o0IaunCHh6jKlW8NxbMSwoNCfqcIKDqPV6Xgjz42Qg=";
    dist = "py3";
    format = "wheel";
    pname = "home_assistant_frontend";
    python = "py3";
  };

  # no Python tests implemented
  doCheck = false;
  # there is nothing to strip in this package
  dontStrip = true;
  format = "wheel";

  meta = {
    description = "Frontend for Home Assistant";
    homepage = "https://github.com/home-assistant/frontend";
    changelog = "https://github.com/home-assistant/frontend/releases/tag/${finalAttrs.version}";
    license = lib.licenses.asl20;
    teams = [ lib.teams.home-assistant ];
  };
})
