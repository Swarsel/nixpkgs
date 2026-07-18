{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  lxml,
  lxml-html-clean,
  pytest-cov-stub,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "justext";
  version = "3.0.2";

  src = fetchFromGitHub {
    owner = "miso-belica";
    repo = "jusText";
    tag = "v${version}";
    hash = "sha256-/7wp41jz/5nUFqZNg4O7yF2+eE+awAEXp6dhD+Loc0U=";
  };

  propagatedBuildInputs = [
    lxml
    lxml-html-clean
  ];

  nativeCheckInputs = [
    pytestCheckHook
    pytest-cov-stub
  ];

  format = "setuptools";
  pythonImportsCheck = [ "justext" ];

  meta = {
    description = "Heuristic based boilerplate removal tool";
    homepage = "https://github.com/miso-belica/jusText";
    changelog = "https://github.com/miso-belica/jusText/blob/${src.tag}/CHANGELOG.rst";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ jokatzke ];
  };
}
