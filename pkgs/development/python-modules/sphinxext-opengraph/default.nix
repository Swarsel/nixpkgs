{
  lib,
  fetchFromGitHub,
  beautifulsoup4,
  buildPythonPackage,
  flit-core,
  matplotlib,
  pytestCheckHook,
  sphinx,
}:

buildPythonPackage rec {
  pname = "sphinxext-opengraph";
  version = "0.13.0";

  src = fetchFromGitHub {
    owner = "wpilibsuite";
    repo = "sphinxext-opengraph";
    tag = "v${version}";
    hash = "sha256-rdV6XWHfNj+TFgIfqFPWYxn6bGG5w/frUHl9+qMALi4=";
  };

  propagatedBuildInputs = [ sphinx ];

  nativeCheckInputs = [
    pytestCheckHook
    beautifulsoup4
  ]
  ++ optional-dependencies.social_cards_generation;

  build-system = [ flit-core ];

  optional-dependencies = {
    social_cards_generation = [ matplotlib ];
  };

  pyproject = true;
  pythonImportsCheck = [ "sphinxext.opengraph" ];

  meta = {
    description = "Sphinx extension to generate unique OpenGraph metadata";
    homepage = "https://github.com/wpilibsuite/sphinxext-opengraph";
    changelog = "https://github.com/wpilibsuite/sphinxext-opengraph/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ Luflosi ];
  };
}
