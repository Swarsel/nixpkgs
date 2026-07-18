{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  mock,
  pexpect,
  pyserial,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pygatt";
  version = "5.0.0";

  src = fetchFromGitHub {
    owner = "peplin";
    repo = "pygatt";
    tag = "v${version}";
    hash = "sha256-TMIqC+JvNOLU38a9jkacRAbdmAAd4UekFUDRoAWhHFo=";
  };

  postPatch = ''
    substituteInPlace setup.py \
      --replace-fail "setup_requires" "test_requires"
  '';

  nativeCheckInputs = [
    mock
    pytestCheckHook
  ]
  ++ optional-dependencies.GATTTOOL;

  build-system = [ setuptools ];
  dependencies = [ pyserial ];
  optional-dependencies.GATTTOOL = [ pexpect ];
  pyproject = true;
  pythonImportsCheck = [ "pygatt" ];
  pythonRemoveDeps = [ "enum-compat" ];

  meta = {
    description = "Python wrapper the BGAPI for accessing Bluetooth LE Devices";
    homepage = "https://github.com/peplin/pygatt";
    changelog = "https://github.com/peplin/pygatt/blob/v${version}/CHANGELOG.rst";

    license = with lib.licenses; [
      asl20
      mit
    ];

    maintainers = with lib.maintainers; [ fab ];
  };
}
