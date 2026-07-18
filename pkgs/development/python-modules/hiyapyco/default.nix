{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  jinja2,
  pyyaml,
  setuptools,
}:

buildPythonPackage rec {
  pname = "hiyapyco";
  version = "0.7.0";

  src = fetchFromGitHub {
    owner = "zerwes";
    repo = "hiyapyco";
    tag = "release-${version}";
    hash = "sha256-uF5DblAg4q8L1tZKopcjJ14NIQVQF5flNHdZ/jnw71M=";
  };

  nativeBuildInputs = [ setuptools ];

  propagatedBuildInputs = [
    pyyaml
    jinja2
  ];

  checkPhase = ''
    runHook preCheck

    set -e
    find test -name 'test_*.py' -exec python {} \;

    runHook postCheck
  '';

  pyproject = true;
  pythonImportsCheck = [ "hiyapyco" ];

  meta = {
    description = "Python library allowing hierarchical overlay of config files in YAML syntax";
    homepage = "https://github.com/zerwes/hiyapyco";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ veehaitch ];
  };
}
