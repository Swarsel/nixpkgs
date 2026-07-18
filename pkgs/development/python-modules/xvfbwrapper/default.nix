{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
  xvfb,
}:

buildPythonPackage rec {
  pname = "xvfbwrapper";
  version = "0.2.18";

  src = fetchFromGitHub {
    owner = "cgoldberg";
    repo = "xvfbwrapper";
    tag = version;
    sha256 = "sha256-iqWDXDzoGAs6Ze1XHrM3HzeqTHbiYU2/CpeZQNzwl0s=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    xvfb
  ];

  build-system = [ setuptools ];
  dependencies = [ xvfb ];
  pyproject = true;

  meta = {
    description = "Run headless displays inside X virtual framebuffers (Xvfb)";
    homepage = "https://github.com/cgoldberg/xvfbwrapper";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ashgillman ];
  };
}
