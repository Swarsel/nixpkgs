{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "types-markdown";
  version = "3.10.2.20260211";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-ZhZDEPiMEaWMbHBglMb4xTfEGONSXTO3Ynal+9ZrAc4=";
    pname = "types_markdown";
  };

  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "markdown-stubs" ];

  meta = {
    description = "Typing stubs for Markdown";
    homepage = "https://pypi.org/project/types-Markdown/";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
})
