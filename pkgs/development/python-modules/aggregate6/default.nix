{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  py-radix,
  pytestCheckHook,
  setuptools,
  versionCheckHook,
}:

buildPythonPackage rec {
  pname = "aggregate6";
  version = "1.0.15";

  src = fetchFromGitHub {
    owner = "job";
    repo = "aggregate6";
    rev = version;
    hash = "sha256-GXIZ2aNZUeiVkhmo2jdwIEk9jL/in2KuuKgi//TQGq0=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    versionCheckHook
  ];

  build-system = [ setuptools ];
  dependencies = [ py-radix ];
  pyproject = true;
  pythonImportsCheck = [ "aggregate6" ];
  versionCheckProgramArg = "-V";

  meta = {
    description = "IPv4 and IPv6 prefix aggregation tool";
    homepage = "https://github.com/job/aggregate6";
    license = with lib.licenses; [ bsd2 ];
    maintainers = with lib.maintainers; [ marcel ];
    mainProgram = "aggregate6";
  };
}
