{
  lib,
  beautifulsoup4,
  buildPythonPackage,
  fetchPypi,
  poetry-core,
  sphinx,
}:

buildPythonPackage (finalAttrs: {
  pname = "sphinxawesome-theme";
  version = "5.3.2";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-BinTi4Cu/CebEYbFOnpvryHnIbWy7NoU9IjKEHTiYx8=";
    pname = "sphinxawesome_theme";
  };

  build-system = [ poetry-core ];

  dependencies = [
    sphinx
    beautifulsoup4
  ];

  pyproject = true;
  pythonRelaxDeps = [ "sphinx" ];

  meta = {
    description = "Awesome Sphinx Theme";
    homepage = "https://sphinxawesome.xyz/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ sigmanificient ];
  };
})
