{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  setuptools,
  unittestCheckHook,
  zope-interface,
  zope-schema,
}:

buildPythonPackage rec {
  pname = "zope-filerepresentation";
  version = "7.0";

  src = fetchFromGitHub {
    owner = "zopefoundation";
    repo = "zope.filerepresentation";
    tag = version;
    hash = "sha256-VWi00b7m+aKwkg/Gfzo5fJWMqdMqgowBpkqsYcEO2gY=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "setuptools ==" "setuptools >="
  '';

  nativeCheckInputs = [ unittestCheckHook ];
  build-system = [ setuptools ];

  dependencies = [
    zope-interface
    zope-schema
  ];

  pyproject = true;
  pythonImportsCheck = [ "zope.filerepresentation" ];
  pythonNamespaces = [ "zope" ];
  unittestFlagsArray = [ "src/zope/filerepresentation" ];

  meta = {
    description = "File-system Representation Interfaces";
    homepage = "https://github.com/zopefoundation/zope.filerepresentation";
    changelog = "https://github.com/zopefoundation/zope.filerepresentation/blob/${version}/CHANGES.rst";
    license = lib.licenses.zpl21;
    maintainers = [ ];
  };
}
