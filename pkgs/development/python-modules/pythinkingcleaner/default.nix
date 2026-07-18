{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  requests,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pythinkingcleaner";
  version = "0.0.3";

  src = fetchFromGitHub {
    owner = "TheRealLink";
    repo = "pythinkingcleaner";
    tag = version;
    hash = "sha256-YaHBZwJvgI3uFkFtZ4KWrKKGRPuNhBBrhCvGC65Jsks=";
  };

  # Package has no tests
  doCheck = false;
  build-system = [ setuptools ];
  dependencies = [ requests ];
  pyproject = true;
  pythonImportsCheck = [ "pythinkingcleaner" ];

  meta = {
    description = "Library to control ThinkingCleaner devices";
    homepage = "https://github.com/TheRealLink/pythinkingcleaner";
    changelog = "https://github.com/TheRealLink/pythinkingcleaner/releases/tag/${version}";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.jamiemagee ];
  };
}
