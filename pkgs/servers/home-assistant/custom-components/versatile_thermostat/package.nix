{
  lib,
  fetchFromGitHub,
  buildHomeAssistantComponent,
  gitUpdater,
  numpy,
  scipy,
  vtherm-api,
}:

buildHomeAssistantComponent rec {
  version = "10.0.2";

  src = fetchFromGitHub {
    inherit owner;
    repo = domain;
    tag = version;
    hash = "sha256-WnhOsvBhIyumWkEiX2Id2fz4GQQTZxBOLPtR6zHqsXw=";
  };

  dependencies = [
    numpy
    scipy
    vtherm-api
  ];

  domain = "versatile_thermostat";
  owner = "jmcollin78";
  passthru.updateScript = gitUpdater { ignoredVersions = "(Alpha|Beta|alpha|beta).*"; };

  meta = {
    description = "Full-featured thermostat";
    homepage = "https://github.com/jmcollin78/versatile_thermostat";
    changelog = "https://github.com/jmcollin78/versatile_thermostat/releases/tag/${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ pwoelfel ];
  };
}
