{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  flask,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage {
  pname = "flask-versioned";
  version = "0.9.4";

  src = fetchFromGitHub {
    owner = "pilt";
    repo = "flask-versioned";
    rev = "38046fb53a09060de437c90a5f7370a6b94ffc31"; # no tags
    hash = "sha256-Z/jwCFTTvxXJpzI+HX9NfBNJxj3MAlbGc7/T0zdMNfI=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  dependencies = [ flask ];
  pyproject = true;
  pythonImportsCheck = [ "flaskext.versioned" ];
  pythonNamespaces = [ "flaskext" ];

  meta = {
    description = "Flask plugin to rewrite file paths to add version info";
    homepage = "https://github.com/pilt/flask-versioned";
    license = lib.licenses.bsd3;
    maintainers = [ ];
  };
}
