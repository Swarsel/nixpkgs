{
  lib,
  fetchFromGitHub,
  addBinToPathHook,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "eliot-tree";
  version = "24.0.0";

  src = fetchFromGitHub {
    owner = "jonathanj";
    repo = "eliottree";
    tag = finalAttrs.version;
    hash = "sha256-4P6eAhX7XBuxu8r/7xvm07u4PZzKP3YLj/5kekgYXG8=";
  };

  nativeCheckInputs = with python3Packages; [
    addBinToPathHook
    pytestCheckHook
    testtools
  ];

  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [
    colored
    eliot
    iso8601
    jmespath
    six
    toolz
  ];

  pyproject = true;
  pythonImportsCheck = [ "eliottree" ];

  meta = {
    description = "Render Eliot logs as an ASCII tree";
    homepage = "https://github.com/jonathanj/eliottree";
    changelog = "https://github.com/jonathanj/eliottree/blob/${finalAttrs.version}/NEWS.rst";
    license = lib.licenses.mit;
    mainProgram = "eliot-tree";
  };
})
