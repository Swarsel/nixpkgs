{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hatchling,
  packaging,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "hatch-requirements-txt";
  version = "0.4.1";

  src = fetchFromGitHub {
    owner = "repo-helper";
    repo = "hatch-requirements-txt";
    tag = "v${version}";
    hash = "sha256-Kd3rDfTBn/t/NiSJMPkHRWD5solUF7MAN8EiZokxHrk=";
  };

  nativeBuildInputs = [ hatchling ];

  propagatedBuildInputs = [
    hatchling
    packaging
  ];

  doCheck = false; # missing coincidence dependency
  nativeCheckInputs = [ pytestCheckHook ];
  pyproject = true;

  meta = {
    description = "Hatchling plugin to read project dependencies from requirements.txt";
    homepage = "https://github.com/repo-helper/hatch-requirements-txt";
    changelog = "https://github.com/repo-helper/hatch-requirements-txt/releases/tag/${version}";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
