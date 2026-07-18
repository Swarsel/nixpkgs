{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  dnspython,
  hatchling,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "pyisemail";
  version = "2.0.1";

  src = fetchFromGitHub {
    owner = "michaelherold";
    repo = "pyIsEmail";
    tag = "v${version}";
    hash = "sha256-bJCaVUhvEAoQ8zMsbcb1Et728XHt+shEPhhBzPzY/vo=";
  };

  nativeBuildInputs = [ hatchling ];
  propagatedBuildInputs = [ dnspython ];
  nativeCheckInputs = [ pytestCheckHook ];
  pyproject = true;
  pythonImportsCheck = [ "pyisemail" ];

  meta = {
    description = "Module for email validation";
    homepage = "https://github.com/michaelherold/pyIsEmail";
    changelog = "https://github.com/michaelherold/pyIsEmail/blob/${version}/CHANGELOG.rst";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
