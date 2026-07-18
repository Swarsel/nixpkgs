{
  lib,
  stdenv,
  fetchFromGitHub,
  beanquery,
  buildPythonPackage,
  fava,
  hatch-vcs,
  hatchling,
  pyyaml,
}:
buildPythonPackage rec {
  pname = "fava-dashboards";
  version = "2.0.1";

  src = fetchFromGitHub {
    owner = "andreasgerstmayr";
    repo = "fava-dashboards";
    tag = "v${version}";
    hash = "sha256-48WS5ymgTN3843Rx3Va5/0ZoLsImrFat8BExOqvhL/c=";
  };

  build-system = [
    hatchling
    hatch-vcs
  ];

  dependencies = [
    beanquery
    fava
    pyyaml
  ];

  pyproject = true;
  pythonImportsCheck = [ "fava_dashboards" ];

  meta = {
    description = "Custom Dashboards for Beancount in Fava";
    homepage = "https://github.com/andreasgerstmayr/fava-dashboards";
    changelog = "https://github.com/andreasgerstmayr/fava-dashboards/blob/main/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ambroisie ];
  };
}
