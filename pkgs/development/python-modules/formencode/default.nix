{
  lib,
  buildPythonPackage,
  dnspython,
  fetchPypi,
  legacy-cgi,
  pycountry,
  pytestCheckHook,
  setuptools-scm,
  six,
}:

buildPythonPackage rec {
  pname = "formencode";
  version = "2.1.1";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-4X8WGZ0jLlT2eRIATzrTM827uBoaGhAjis8JurmfkZk=";
  };

  postPatch = ''
    sed -i '/setuptools_scm_git_archive/d' setup.py
  '';

  nativeCheckInputs = [
    dnspython
    pycountry
    pytestCheckHook
  ];

  build-system = [ setuptools-scm ];

  dependencies = [
    six
    legacy-cgi
  ];

  disabledTests = [
    # requires network for DNS resolution
    "test_doctests"
    "test_unicode_ascii_subgroup"
  ];

  pyproject = true;

  meta = {
    description = "FormEncode validates and converts nested structures";
    homepage = "http://formencode.org";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
