{
  lib,
  fetchFromGitHub,
  buildHomeAssistantComponent,
  home-assistant,
  httpx,
  pytest-asyncio,
  pytest-cov-stub,
  pytest-homeassistant-custom-component,
  pytestCheckHook,
}:

buildHomeAssistantComponent rec {
  version = "2.9.2";

  src = fetchFromGitHub {
    inherit owner;
    repo = "blueprints-updater";
    tag = version;
    hash = "sha256-b6DBrG1c7reIomg9/ZrQgDig976PAbCKIl9AfA/RtmY=";
  };

  patches = [
    # Do not skip blueprints symlinked from the nix store.
    # They cannot be updated, but users probably still want to be notified if they have an update.
    ./allow-symlinked-blueprints.diff
  ];

  postPatch = ''
    # avoid dependency on rather big pytest-timeout
    substituteInPlace pyproject.toml \
      --replace-fail '"--timeout=60",' ""
  '';

  nativeCheckInputs = [
    home-assistant
    pytest-asyncio
    pytest-cov-stub
    pytest-homeassistant-custom-component
    pytestCheckHook
  ];

  dependencies = httpx.optional-dependencies.http2;

  disabledTestPaths = [
    # pytest-homeassistant-custom-component tries to create temporary directories inside the nix store
    "tests/integration/test_init.py::test_full_update_lifecycle"
    "tests/integration/test_services.py::test_restore_blueprint_service"
    "tests/integration/test_services.py::test_update_all_service"
  ];

  domain = "blueprints_updater";
  owner = "luuquangvu";

  meta = {
    description = "Automatically update Home Assistant blueprints via native update entities";
    homepage = "https://github.com/luuquangvu/blueprints-updater/";
    changelog = "https://github.com/luuquangvu/blueprints-updater/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ SuperSandro2000 ];
  };
}
