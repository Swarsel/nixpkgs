{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  colorama,
  libunwind,
  pytestCheckHook,
  pythonAtLeast,
  pytz,
  requests,
  setuptools,
  six,
}:

buildPythonPackage rec {
  pname = "vmprof";
  version = "0.4.17";

  src = fetchFromGitHub {
    owner = "vmprof";
    repo = "vmprof-python";
    tag = version;
    hash = "sha256-7k6mtEdPmp1eNzB4l/k/ExSYtRJVmRxcx50ql8zR36k=";
  };

  buildInputs = [ libunwind ];
  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];

  dependencies = [
    colorama
    requests
    six
    pytz
  ];

  disabled = pythonAtLeast "3.12";

  disabledTests = [
    "test_gzip_call"
    "test_is_enabled"
    "test_get_profile_path"
    "test_get_runtime"
  ];

  pyproject = true;
  pythonImportsCheck = [ "vmprof" ];

  meta = {
    description = "Vmprof client";
    homepage = "https://vmprof.readthedocs.org/";
    license = lib.licenses.mit;
    mainProgram = "vmprofshow";
  };
}
