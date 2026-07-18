{
  lib,
  fetchFromGitHub,
  buildHomeAssistantComponent,
}:
buildHomeAssistantComponent rec {
  version = "0.4.4";

  src = fetchFromGitHub {
    inherit owner;
    repo = "ha-nest-protect";
    tag = "v${version}";
    hash = "sha256-WpQKpYVtmyqLWqhyDsImWvpfWagVWe50zG0RsmeU/8Q=";
  };

  # AttributeError: 'async_generator' object has no attribute 'data'
  doCheck = false;
  domain = "nest_protect";
  owner = "iMicknl";

  meta = {
    description = "Nest Protect integration for Home Assistant";
    homepage = "https://github.com/iMicknl/ha-nest-protect";
    changelog = "https://github.com/iMicknl/ha-nest-protect/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ jamiemagee ];
  };
}
