{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  click,
  poetry-core,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "click-aliases";
  version = "1.0.6";

  src = fetchFromGitHub {
    owner = "click-contrib";
    repo = "click-aliases";
    rev = "v${version}";
    hash = "sha256-nHUvzUiWc7Fq22PPsodIDOwU1INy2CQfztD0ceguhEo=";
  };

  nativeBuildInputs = [ poetry-core ];
  propagatedBuildInputs = [ click ];
  nativeCheckInputs = [ pytestCheckHook ];
  pyproject = true;
  pythonImportsCheck = [ "click_aliases" ];

  meta = {
    description = "Enable aliases for click";
    homepage = "https://github.com/click-contrib/click-aliases";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ panicgh ];
  };
}
