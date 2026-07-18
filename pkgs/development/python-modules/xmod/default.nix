{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  poetry-core,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "xmod";
  version = "1.8.1";

  src = fetchFromGitHub {
    owner = "rec";
    repo = "xmod";
    rev = "v${version}";
    hash = "sha256-pfFxtDQ4kaBrx4XzYMQO1vE4dUr2zs8jgGUQUdXB798=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ poetry-core ];
  disabledTests = [ "test_partial_function" ];
  pyproject = true;
  pythonImportsCheck = [ "xmod" ];

  meta = {
    description = "Turn any object into a module";
    homepage = "https://github.com/rec/xmod";
    changelog = "https://github.com/rec/xmod/blob/${src.rev}/CHANGELOG";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
