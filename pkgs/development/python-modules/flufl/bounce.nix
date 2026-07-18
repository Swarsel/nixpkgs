{
  lib,
  atpublic,
  buildPythonPackage,
  fetchPypi,
  fetchpatch2,
  pytestCheckHook,
  setuptools,
  zope-interface,
}:

buildPythonPackage rec {
  pname = "flufl-bounce";
  version = "4.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-JVBK65duwP5aGc1sQTo0EMtRT9zb3Kn5tdjTQ6hgODE=";
    pname = "flufl.bounce";
  };

  patches = [
    (fetchpatch2 {
      hash = "sha256-HJHEbRVjiiP5Z7W0sQCj6elUMyaWOTqQw6UpYOYCVZM=";
      # Replace deprecated failIf with assertFalse for Python 3.12 compatibility.
      url = "https://gitlab.com/warsaw/flufl.bounce/-/commit/e0b9fd0f24572e024a8d0484a3c9fb4542337d18.patch";
    })
  ];

  nativeBuildInputs = [ setuptools ];

  propagatedBuildInputs = [
    atpublic
    zope-interface
  ];

  nativeCheckInputs = [ pytestCheckHook ];
  pyproject = true;
  pythonImportsCheck = [ "flufl.bounce" ];
  pythonNamespaces = [ "flufl" ];

  meta = {
    description = "Email bounce detectors";
    homepage = "https://gitlab.com/warsaw/flufl.bounce";
    changelog = "https://gitlab.com/warsaw/flufl.bounce/-/blob/${version}/flufl/bounce/NEWS.rst";
    license = lib.licenses.asl20;
    maintainers = [ ];
  };
}
