{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  click,
  distro,
  # tests
  freezegun,
  gevent,
  # build-system
  hatchling,
  jinja2,
  packaging,
  paramiko,
  pydantic,
  pyinfra-testgen,
  pytest-testinfra,
  pytestCheckHook,
  python-dateutil,
  typeguard,
  types-paramiko,
  uv-dynamic-versioning,
  versionCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "pyinfra";
  version = "3.9.2";

  src = fetchFromGitHub {
    owner = "Fizzadar";
    repo = "pyinfra";
    tag = "v${finalAttrs.version}";
    hash = "sha256-5qgPfBtPqysEtNCLFAgGAxlVK/CRH9VYmiC/98VWomI=";
  };

  nativeCheckInputs = [
    freezegun
    pyinfra-testgen
    pytest-testinfra
    pytestCheckHook
    versionCheckHook
  ];

  __structuredAttrs = true;

  build-system = [
    hatchling
    uv-dynamic-versioning
  ];

  dependencies = [
    click
    distro
    gevent
    jinja2
    packaging
    paramiko
    pydantic
    python-dateutil
    typeguard
    types-paramiko
  ];

  disabledTests = [
    # Test requires SSH binary
    "test_load_ssh_config"
  ];

  pyproject = true;
  pythonImportsCheck = [ "pyinfra" ];

  meta = {
    description = "Python-based infrastructure automation";

    longDescription = ''
      pyinfra automates/provisions/manages/deploys infrastructure. It can be used for
      ad-hoc command execution, service deployment, configuration management and more.
    '';

    homepage = "https://pyinfra.com";
    changelog = "https://github.com/Fizzadar/pyinfra/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ totoroot ];
    mainProgram = "pyinfra";
    downloadPage = "https://pyinfra.com/Fizzadar/pyinfra/releases";
  };
})
