{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  flit-core,
  pytestCheckHook,
  typing-extensions,
}:

buildPythonPackage (finalAttrs: {
  pname = "asyncstdlib";
  version = "3.14.0";

  src = fetchFromGitHub {
    owner = "maxfischer2781";
    repo = "asyncstdlib";
    tag = "v${finalAttrs.version}";
    hash = "sha256-zp6F+Otb1d8kqdLO99shBA7ny7Zjq027T2dtTGHTcqI=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    typing-extensions
  ];

  build-system = [ flit-core ];
  pyproject = true;
  pythonImportsCheck = [ "asyncstdlib" ];

  meta = {
    description = "Python library that extends the Python asyncio standard library";
    homepage = "https://asyncstdlib.readthedocs.io/";
    changelog = "https://github.com/maxfischer2781/asyncstdlib/releases/tag/${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
})
