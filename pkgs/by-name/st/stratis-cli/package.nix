{
  lib,
  fetchFromGitHub,
  nixosTests,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "stratis-cli";
  version = "3.8.3";

  src = fetchFromGitHub {
    owner = "stratis-storage";
    repo = "stratis-cli";
    tag = "v${finalAttrs.version}";
    hash = "sha256-wkFInG/sbHxyi5UIjIANxsTd9BrIHuyAfYG4DvqLsmU=";
  };

  env.STRATIS_STRICT_POOL_FEATURES = "1"; # required for unit tests

  nativeCheckInputs = with python3Packages; [
    pytestCheckHook
  ];

  build-system = with python3Packages; [
    setuptools
  ];

  dependencies = with python3Packages; [
    dbus-client-gen
    dbus-python-client-gen
    justbytes
    packaging
    psutil
    python-dateutil
    wcwidth
  ];

  disabledTestPaths = [
    # tests below require dbus daemon
    "tests/whitebox/integration"
  ];

  pyproject = true;
  pythonImportsCheck = [ "stratis_cli" ];
  passthru.tests = nixosTests.stratis;

  meta = {
    description = "CLI for the Stratis project";
    homepage = "https://stratis-storage.github.io";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ nickcao ];
    mainProgram = "stratis";
  };
})
