{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "oscpy";
  version = "0.6.1";

  src = fetchFromGitHub {
    owner = "kivy";
    repo = "oscpy";
    tag = "v${version}";
    hash = "sha256-sumpJ2y9lpd0UhQjk4zVDp3SipBwh3NBkJ3dqWs18IE=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  format = "setuptools";
  pythonImportsCheck = [ "oscpy" ];

  meta = {
    description = "Modern implementation of OSC for python2/3";
    homepage = "https://github.com/kivy/oscpy";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.yurkobb ];
    mainProgram = "oscli";
  };
}
