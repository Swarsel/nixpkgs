{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  click,
  pycountry-convert,
  pycryptodome,
  pytestCheckHook,
  requests,
  requests-mock,
  setuptools,
  sleekxmppfs,
}:

buildPythonPackage rec {
  pname = "py-sucks";
  version = "0.9.11";

  src = fetchFromGitHub {
    owner = "mib1185";
    repo = "py-sucks";
    tag = "v${version}";
    hash = "sha256-srj/3x04R9KgbdC6IgbQdgUz+srAx0OttB6Ndb2+Nh4=";
  };

  nativeCheckInputs = [
    requests-mock
    pytestCheckHook
  ]
  ++ lib.concatAttrValues optional-dependencies;

  build-system = [ setuptools ];

  dependencies = [
    pycryptodome
    requests
    sleekxmppfs
  ];

  disabledTests = [
    # assumes $HOME is at a specific place
    "test_config_file_name"
  ];

  optional-dependencies = {
    cli = [
      click
      pycountry-convert
    ];
  };

  pyproject = true;
  pythonImportsCheck = [ "sucks" ];

  meta = {
    description = "Library for controlling certain robot vacuums";
    homepage = "https://github.com/mib1185/py-sucks";
    changelog = "https://github.com/mib1185/py-sucks/releases/tag/${src.tag}";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ dotlambda ];
    mainProgram = "sucks";
  };
}
