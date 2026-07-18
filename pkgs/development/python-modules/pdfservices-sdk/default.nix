{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  defusedxml,
  requests,
  setuptools,
  sphinx,
  sphinx-rtd-theme,
}:

buildPythonPackage rec {
  pname = "pdfservices-sdk";
  version = "4.2.0";

  src = fetchFromGitHub {
    owner = "adobe";
    repo = "pdfservices-python-sdk";
    tag = "v${version}";
    hash = "sha256-m2k+IS+M8UrdrpLnk2OwRolAVq73StMY1WnxzOujBIM=";
  };

  build-system = [
    setuptools
  ];

  dependencies = [
    defusedxml
    requests
    sphinx
    sphinx-rtd-theme
  ];

  pyproject = true;

  pythonImportsCheck = [
    "adobe.pdfservices"
  ];

  pythonRelaxDeps = true;

  meta = {
    description = "Adobe PDFServices Python SDK";
    homepage = "https://github.com/adobe/pdfservices-python-sdk";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
    maintainers = with lib.maintainers; [ hhr2020 ];
  };
}
