{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
  six,
}:

buildPythonPackage rec {
  pname = "paste";
  version = "3.10.1";

  src = fetchFromGitHub {
    owner = "pasteorg";
    repo = "paste";
    tag = version;
    hash = "sha256-NY/h6hbpluEu1XAv3o4mqoG+l0LXfM1dw7+G0Rm1E4o=";
  };

  postPatch = ''
    patchShebangs tests/cgiapp_data/
  '';

  nativeCheckInputs = [ pytestCheckHook ];

  preCheck = ''
    # needs to be modified after Sat, 1 Jan 2005 12:00:00 GMT
    touch tests/urlparser_data/secured.txt
  '';

  build-system = [ setuptools ];

  dependencies = [
    setuptools
    six
  ];

  disabledTests = [
    # pkg_resources deprecation warning
    "test_form"
  ];

  pyproject = true;
  pythonNamespaces = [ "paste" ];

  meta = {
    description = "Tools for using a Web Server Gateway Interface stack";
    homepage = "https://pythonpaste.readthedocs.io/";
    changelog = "https://github.com/pasteorg/paste/blob/${version}/docs/news.txt";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
