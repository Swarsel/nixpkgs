{
  lib,
  buildPythonPackage,
  fetchPypi,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "exdown";
  version = "0.9.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-+IN+0P4SljUWxF01Ln9PgeFVA/+qGKFVoKMGluAuYDw=";
    extension = "zip";
  };

  nativeBuildInputs = [ setuptools ];
  nativeCheckInputs = [ pytestCheckHook ];
  pyproject = true;
  pythonImportsCheck = [ "exdown" ];

  meta = {
    description = "Extract code blocks from markdown";
    homepage = "https://github.com/nschloe/exdown";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
