{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cffi,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "miniaudio";
  version = "1.71";

  src = fetchFromGitHub {
    owner = "irmen";
    repo = "pyminiaudio";
    tag = "v${version}";
    hash = "sha256-fBdRricV0eqQknOQInB3cj8reZGKS9hrJTMF1ILASpY=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  # TODO: Properly unvendor miniaudio c library
  build-system = [ setuptools ];
  dependencies = [ cffi ];
  propagatedNativeBuildInputs = [ cffi ];
  pyproject = true;
  pythonImportsCheck = [ "miniaudio" ];

  meta = {
    description = "Python bindings for the miniaudio library and its decoders";
    homepage = "https://github.com/irmen/pyminiaudio";
    changelog = "https://github.com/irmen/pyminiaudio/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
