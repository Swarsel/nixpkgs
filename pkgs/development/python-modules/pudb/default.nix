{
  lib,
  buildPythonPackage,
  fetchPypi,
  hatchling,
  jedi,
  packaging,
  pygments,
  pytest-mock,
  pytestCheckHook,
  urwid,
  urwid-readline,
}:

buildPythonPackage rec {
  pname = "pudb";
  version = "2025.1.5";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-5t7bgfw8jNzWbPYuhjN8uRNXDrssmUyatSAS0Fnghq0=";
  };

  nativeCheckInputs = [
    pytest-mock
    pytestCheckHook
  ];

  preCheck = ''
    export HOME=$TMPDIR
  '';

  build-system = [ hatchling ];

  dependencies = [
    jedi
    packaging
    pygments
    urwid
    urwid-readline
  ];

  pyproject = true;
  pythonImportsCheck = [ "pudb" ];

  meta = {
    description = "Full-screen, console-based Python debugger";
    homepage = "https://github.com/inducer/pudb";
    changelog = "https://github.com/inducer/pudb/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "pudb";
  };
}
