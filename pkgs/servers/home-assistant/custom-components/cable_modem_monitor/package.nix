{
  lib,
  fetchFromGitHub,
  beautifulsoup4,
  buildHomeAssistantComponent,
  buildPythonPackage,
  cryptography,
  defusedxml,
  hatchling,
  nix-update-script,
  pydantic,
  pytest-cov-stub,
  pytest-homeassistant-custom-component,
  pytest-socket,
  pytestCheckHook,
  pyyaml,
  requests,
}:
let
  version = "3.14.0-beta.13";
  src = fetchFromGitHub {
    owner = "solentlabs";
    repo = "cable_modem_monitor";
    tag = "v${version}";
    hash = "sha256-biQVMq2IoOdbpdP+zDfLXdl91++aKmN3EPQfvzEACyU=";
    fetchLFS = true;
  };

  core = buildPythonPackage (finalAttrs: {
    inherit src version;
    pname = "solentlabs-cable-modem-monitor-core";

    nativeCheckInputs = [
      cryptography
      pytestCheckHook
      pytest-cov-stub
      pytest-socket
    ];

    build-system = [ hatchling ];

    dependencies = [
      beautifulsoup4
      defusedxml
      pydantic
      pyyaml
      requests
    ];

    pyproject = true;
    sourceRoot = "${finalAttrs.src.name}/packages/cable_modem_monitor_core";
  });

  catalog = buildPythonPackage (finalAttrs: {
    inherit src version;
    pname = "solentlabs-cable-modem-monitor-catalog";

    nativeCheckInputs = [
      cryptography
      pytestCheckHook
      pytest-socket
    ];

    build-system = [ hatchling ];

    dependencies = [
      core
    ];

    pyproject = true;
    sourceRoot = "${finalAttrs.src.name}/packages/cable_modem_monitor_catalog";
  });
in
buildHomeAssistantComponent rec {
  inherit src version;

  nativeCheckInputs = [
    pytestCheckHook
    pytest-homeassistant-custom-component
  ];

  dependencies = [
    catalog
    core
  ];

  domain = "cable_modem_monitor";
  owner = "solentlabs";
  passthru.updateScript = nix-update-script { extraArgs = [ "--version=unstable" ]; };

  meta = {
    description = "Home Assistant integration for monitoring cable modem signal quality";
    homepage = "https://solentlabs.io/cable-modem-monitor";
    changelog = "https://github.com/solentlabs/cable_modem_monitor/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ RoGreat ];
  };
}
