{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
  xstatic-jquery,
}:

buildPythonPackage (finalAttrs: {
  pname = "xstatic-jquery-file-upload";
  version = "10.31.0.1";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-fXFvJqyhRzLDXFTwum04GHYAq0cvyYqR2XLRLFpw2yc=";
    pname = "XStatic-jQuery-File-Upload";
  };

  # no tests implemented
  doCheck = false;
  __structuredAttrs = true;
  build-system = [ setuptools ];
  dependencies = [ xstatic-jquery ];
  pyproject = true;
  pythonImportsCheck = [ "xstatic.pkg.jquery_file_upload" ];

  meta = {
    description = "jquery-file-upload packaged static files for python";
    homepage = "https://github.com/blueimp/jQuery-File-Upload";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ makefu ];
  };
})
