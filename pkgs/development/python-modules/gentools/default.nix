{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  poetry-core,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "gentools";
  version = "1.2.2";

  src = fetchFromGitHub {
    owner = "ariebovenberg";
    repo = "gentools";
    tag = "v${version}";
    hash = "sha256-+6KTFxOpwvGOCqy6JU87gOZmDa6MvjR10qES5wIfrjI=";
  };

  nativeBuildInputs = [ poetry-core ];
  nativeCheckInputs = [ pytestCheckHook ];
  pyproject = true;
  pythonImportsCheck = [ "gentools" ];

  meta = {
    description = "Tools for generators, generator functions, and generator-based coroutines";
    homepage = "https://gentools.readthedocs.io/";
    changelog = "https://github.com/ariebovenberg/gentools/blob/v${version}/CHANGELOG.rst";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
