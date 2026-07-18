{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  setuptools,
}:

buildPythonPackage rec {
  pname = "forbiddenfruit";
  version = "0.1.4";

  src = fetchFromGitHub {
    owner = "clarete";
    repo = "forbiddenfruit";
    tag = version;
    hash = "sha256-yHIZsVn2UVmWeBNIzWDE6AOwAXZilPqXo+bVtXqGkJk=";
  };

  env.FFRUIT_EXTENSION = "true";
  doCheck = false; # uses nose
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "forbiddenfruit" ];

  meta = {
    description = "Patch python built-in objects";
    homepage = "https://github.com/clarete/forbiddenfruit";
    changelog = "https://github.com/clarete/forbiddenfruit/releases/tag/${version}";

    license = with lib.licenses; [
      mit
      gpl3Plus
    ];

    maintainers = [ ];
  };
}
