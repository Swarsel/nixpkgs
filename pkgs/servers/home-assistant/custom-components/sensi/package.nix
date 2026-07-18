{
  lib,
  fetchFromGitHub,
  buildHomeAssistantComponent,
  python-socketio,
}:
buildHomeAssistantComponent rec {
  version = "2.1.4";

  src = fetchFromGitHub {
    inherit owner;
    repo = domain;
    tag = "v${version}";
    hash = "sha256-FTyFxQd2upNUKhfSfd5rEr5BLpu6veYHrExHUazTamU=";
  };

  postPatch = ''
    substituteInPlace custom_components/sensi/manifest.json \
      --replace-fail "==" ">="
  '';

  dependencies = [
    python-socketio
  ];

  domain = "sensi";
  owner = "iprak";

  meta = {
    description = "HomeAssistant integration for Sensi thermostat";
    homepage = "https://github.com/iprak/sensi";
    changelog = "https://github.com/iprak/sensi/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
