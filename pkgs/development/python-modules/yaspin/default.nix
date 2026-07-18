{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  poetry-core,
  pytest-mock,
  pytest-xdist,
  pytestCheckHook,
  termcolor,
}:

buildPythonPackage rec {
  pname = "yaspin";
  version = "3.4.0";

  src = fetchFromGitHub {
    owner = "pavdmyt";
    repo = "yaspin";
    tag = "v${version}";
    hash = "sha256-uHW0lSkmNYZh4OGCFgaiIoqhY6KFojSyyEezTNxYqMw=";
  };

  nativeCheckInputs = [
    pytest-mock
    pytest-xdist
    pytestCheckHook
  ];

  # tests assert for \033 which gets turned off in termcolor when TERM dumb is used which is used by nix
  preCheck = ''
    export FORCE_COLOR=1
  '';

  build-system = [ poetry-core ];
  dependencies = [ termcolor ];
  pyproject = true;
  pythonImportsCheck = [ "yaspin" ];

  pythonRelaxDeps = [
    "termcolor"
  ];

  meta = {
    description = "Yet Another Terminal Spinner";
    homepage = "https://github.com/pavdmyt/yaspin";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ samuela ];
  };
}
