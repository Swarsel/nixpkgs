{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "pysnooper";
  version = "1.2.3";

  src = fetchFromGitHub {
    owner = "cool-RR";
    repo = "PySnooper";
    tag = finalAttrs.version;
    hash = "sha256-+Cjqi0xkWO4QVAZymmcper4dal9pNWbpPgPY4UzbXfA=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];

  disabledTests = lib.optionals stdenv.hostPlatform.isDarwin [
    # timing-sensitive and often breaks on Darwin
    "test_relative_time"
  ];

  pyproject = true;
  pythonImportsCheck = [ "pysnooper" ];

  meta = {
    description = "Poor man's debugger for Python";
    homepage = "https://github.com/cool-RR/PySnooper";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ seqizz ];
  };
})
