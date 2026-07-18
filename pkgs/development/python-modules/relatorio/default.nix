{
  lib,
  buildPythonPackage,
  fetchPypi,
  genshi,
  lxml,
  pytestCheckHook,
  python-magic,
  pyyaml,
}:

buildPythonPackage rec {
  pname = "relatorio";
  version = "0.11.1";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-e6CvclFrRfXR5fL2ZG1LZxTTsTRouLsDicCwvXtySGE=";
  };

  propagatedBuildInputs = [
    genshi
    lxml
  ];

  nativeCheckInputs = [ pytestCheckHook ] ++ optional-dependencies.fodt;
  format = "setuptools";

  optional-dependencies = {
    chart = [
      # pycha
      pyyaml
    ];

    fodt = [ python-magic ];
  };

  pythonImportsCheck = [ "relatorio" ];

  meta = {
    description = "Templating library able to output odt and pdf files";
    homepage = "https://relatorio.tryton.org/";
    changelog = "https://hg.tryton.org/relatorio/file/${version}/CHANGELOG";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ johbo ];
    mainProgram = "relatorio-render";
  };
}
