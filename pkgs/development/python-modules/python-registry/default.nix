{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
  six,
  unicodecsv,
}:

buildPythonPackage rec {
  pname = "python-registry";
  version = "1.4";

  src = fetchFromGitHub {
    owner = "williballenthin";
    repo = "python-registry";
    tag = version;
    hash = "sha256-OgRPcyx+NJnbtETMakUT0p8Pb0Qfzgj+qvWtmJksnT8=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    six
  ];

  build-system = [ setuptools ];
  dependencies = [ unicodecsv ];
  disabledTestPaths = [ "samples" ];
  pyproject = true;
  pythonImportsCheck = [ "Registry" ];
  pythonRemoveDeps = [ "enum-compat" ];

  meta = {
    description = "Module to parse the Windows Registry hives";
    homepage = "https://github.com/williballenthin/python-registry";
    changelog = "https://github.com/williballenthin/python-registry/releases/tag/${version}";
    license = lib.licenses.asl20;
    maintainers = [ ];
  };
}
