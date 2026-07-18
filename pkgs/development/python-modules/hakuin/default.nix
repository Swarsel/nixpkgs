{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  hatchling,
  jinja2,
  nltk,
  sqlglot,
}:

buildPythonPackage rec {
  pname = "hakuin";
  version = "0.2.2";

  src = fetchFromGitHub {
    owner = "pruzko";
    repo = "hakuin";
    tag = version;
    hash = "sha256-97nh+woUsCXcoO2i5KprCwJiE24V3mg91qcNgy7bpgg=";
  };

  # Module has no test
  doCheck = false;
  build-system = [ hatchling ];

  dependencies = [
    aiohttp
    jinja2
    nltk
    sqlglot
  ];

  pyproject = true;
  pythonImportsCheck = [ "hakuin" ];

  meta = {
    description = "Blind SQL Injection optimization and automation framework";
    homepage = "https://github.com/pruzko/hakuin";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
