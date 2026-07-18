{
  lib,
  fetchFromGitHub,
  buildHomeAssistantComponent,
  fnv-hash-fast,
  pillow,
  psutil-home-assistant,
  sqlalchemy,
}:
buildHomeAssistantComponent rec {
  version = "5.0.0";

  src = fetchFromGitHub {
    inherit owner;
    repo = domain;
    tag = "v${version}";
    hash = "sha256-tIVEI5oZcvI0uyCQfajb1WVldkx7aQF8gV0UBWYPUnI=";
  };

  patches = [ ./remove-sub-integration-symlink-hack.patch ];

  postPatch = ''
    substituteInPlace custom_components/spook/manifest.json \
      --replace-fail '"version": "0.0.0"' '"version": "${version}"'
  '';

  dependencies = [
    pillow
    fnv-hash-fast
    psutil-home-assistant
    sqlalchemy
  ];

  domain = "spook";
  owner = "frenck";

  meta = {
    description = "Toolbox for Home Assistant";
    homepage = "https://spook.boo/";
    changelog = "https://github.com/frenck/spook/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ kkoniuszy ];
  };
}
