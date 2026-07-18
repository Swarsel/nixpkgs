{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pycoolmasternet-async";
  version = "0.2.4";

  src = fetchFromGitHub {
    owner = "OnFreund";
    repo = "pycoolmasternet-async";
    tag = "v${version}";
    hash = "sha256-C2JNAg7FdZ0Sfr7HGCQaBOQdWbeDtpBIIhCq3Htsx84=";
  };

  # no tests implemented
  doCheck = false;
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "pycoolmasternet_async" ];

  meta = {
    description = "Python library to control CoolMasterNet HVAC bridges over asyncio";
    homepage = "https://github.com/OnFreund/pycoolmasternet-async";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
