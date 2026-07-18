{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  pythonAtLeast,
  setuptools,
  standard-telnetlib,
}:

buildPythonPackage rec {
  pname = "ndms2-client";
  version = "0.1.3";

  src = fetchFromGitHub {
    owner = "foxel";
    repo = "python_ndms2_client";
    rev = version;
    hash = "sha256-A19olC1rTHTy0xyeSP45fqvv9GUynQSrMgXBgW8ySOs=";
  };

  nativeBuildInputs = [ setuptools ];
  nativeCheckInputs = [ pytestCheckHook ];
  dependencies = lib.optionals (pythonAtLeast "3.13") [ standard-telnetlib ];
  pyproject = true;
  pythonImportsCheck = [ "ndms2_client" ];

  meta = {
    description = "Keenetic NDMS 2.x and 3.x client";
    homepage = "https://github.com/foxel/python_ndms2_client";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
