{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  flit-core,
  packaging,
  sphinx,
  sphinx-notfound-page,
}:

buildPythonPackage rec {
  pname = "pallets-sphinx-themes";
  version = "2.3.0";

  src = fetchFromGitHub {
    owner = "pallets";
    repo = "pallets-sphinx-themes";
    tag = version;
    hash = "sha256-+etmWzjCiYbM8cHSnJr0tHs3DpvozNYShQ6x60UADS4=";
  };

  build-system = [
    flit-core
  ];

  dependencies = [
    packaging
    sphinx
    sphinx-notfound-page
  ];

  pyproject = true;
  pythonImportsCheck = [ "pallets_sphinx_themes" ];

  meta = {
    description = "Sphinx theme for Pallets projects";
    homepage = "https://github.com/pallets/pallets-sphinx-themes";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ kaction ];
  };
}
