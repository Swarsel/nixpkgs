{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hypothesis,
  packaging,
  poetry-core,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "rmscene";
  version = "0.8.0";

  src = fetchFromGitHub {
    owner = "ricklupton";
    repo = "rmscene";
    tag = "v${version}";
    hash = "sha256-AejIkrvNIgUoNtDJwqPvMMToa12dnZQDKWvNztOgAvc=";
  };

  nativeCheckInputs = [
    hypothesis
    pytestCheckHook
  ];

  build-system = [
    poetry-core
  ];

  dependencies = [ packaging ];
  pyproject = true;
  pythonImportsCheck = [ "rmscene" ];
  pythonRelaxDeps = [ "packaging" ];

  meta = {
    description = "Read v6 .rm files from the reMarkable tablet";
    homepage = "https://github.com/ricklupton/rmscene";
    changelog = "https://github.com/ricklupton/rmscene/blob/${src.tag}/README.md#changelog";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
