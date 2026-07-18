{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pyparsing,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "grandalf";
  version = "0.8";

  src = fetchFromGitHub {
    owner = "bdcht";
    repo = "grandalf";
    tag = "v${version}";
    hash = "sha256-oKuzk/vsEkoiEPgt/fsaaurKfz5CElXPEJe88aFBLqU=";
  };

  patches = [ ./no-setup-requires-pytestrunner.patch ];
  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  dependencies = [ pyparsing ];
  pyproject = true;
  pythonImportsCheck = [ "grandalf" ];

  meta = {
    description = "Module for experimentations with graphs and drawing algorithms";
    homepage = "https://github.com/bdcht/grandalf";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ cmcdragonkai ];
  };
}
