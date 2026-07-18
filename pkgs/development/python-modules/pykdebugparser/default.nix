{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  click,
  construct,
  pygments,
  pytestCheckHook,
  setuptools,
  termcolor,
}:

buildPythonPackage rec {
  pname = "pykdebugparser";
  version = "1.2.7";

  src = fetchFromGitHub {
    owner = "matan1008";
    repo = "pykdebugparser";
    tag = "v${version}";
    hash = "sha256-V6WyFsPcjiBUJ+Amc3xk0GwdHzwakRizB/dPnSXT6vo=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    click
    construct
    pygments
    termcolor
  ];

  pyproject = true;
  pythonImportsCheck = [ "pykdebugparser" ];

  meta = {
    description = "Kdebug events and ktraces parser";
    homepage = "https://github.com/matan1008/pykdebugparser";
    changelog = "https://github.com/matan1008/pykdebugparser/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.dotlambda ];
    mainProgram = "pykdebugparser";
  };
}
