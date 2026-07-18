{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  setuptools,
}:

buildPythonPackage rec {
  pname = "iglo";
  version = "1.2.7";

  src = fetchFromGitHub {
    owner = "jesserockz";
    repo = "python-iglo";
    tag = "v${version}";
    hash = "sha256-torDjfQcQ+ytv/Qab7PNugt1eLQJ0pPPz6p4f4kcFws=";
  };

  # Package has no tests
  doCheck = false;
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "iglo" ];
  sourceRoot = "${src.name}/src";

  meta = {
    description = "Library to control iGlo based RGB lights";
    homepage = "https://github.com/jesserockz/python-iglo";
    changelog = "https://github.com/jesserockz/python-iglo/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.jamiemagee ];
  };
}
