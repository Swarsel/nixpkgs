{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  setuptools,
}:

buildPythonPackage rec {
  pname = "psychrolib";
  version = "2.5.0";

  src = fetchFromGitHub {
    owner = "psychrometrics";
    repo = "psychrolib";
    tag = version;
    hash = "sha256-OkjoYIakF7NXluNTaJnUHk5cI5t8GnpqrbqHYwnLOts=";
  };

  nativeBuildInputs = [ setuptools ];
  # Module has no tests
  doCheck = false;
  format = "setuptools";
  pythonImportsCheck = [ "psychrolib" ];
  sourceRoot = "${src.name}/src/python";

  meta = {
    description = "Library of psychrometric functions to calculate thermodynamic properties";
    homepage = "https://github.com/psychrometrics/psychrolib";
    changelog = "https://github.com/psychrometrics/psychrolib/releases/tag/${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
