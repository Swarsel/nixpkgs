{
  lib,
  buildPythonPackage,
  fetchPypi,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "biplist";
  version = "1.0.3";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-TAVJdkxf5QsoBC7CGqLhT+GiIk4jmh2ud9nn85MqpMY=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  __structuredAttrs = true;
  build-system = [ setuptools ];

  disabledTests = [
    # Failing tests
    "testConvertToXMLPlistWithData"
    "testWriteToFile"
    "testXMLPlist"
    "testXMLPlistWithData"
  ];

  pyproject = true;
  pythonImportsCheck = [ "biplist" ];

  meta = {
    description = "Binary plist parser/generator for Python";

    longDescription = ''
      Binary Property List (plist) files provide a faster and smaller
      serialization format for property lists on OS X.

      This is a library for generating binary plists which can be read
      by OS X, iOS, or other clients.
    '';

    homepage = "https://bitbucket.org/wooster/biplist/src/master/";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ siriobalmelli ];
  };
})
