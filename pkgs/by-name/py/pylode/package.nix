{
  lib,
  fetchFromGitHub,
  python3,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "pylode";
  version = "3.2.3";

  src = fetchFromGitHub {
    owner = "RDFLib";
    repo = "pylode";
    tag = finalAttrs.version;
    hash = "sha256-b1asjzkatSbe5HRqGPf808wjnJTwOaYKABPyO+jSd8c=";
  };

  # Path issues with the tests
  doCheck = false;
  build-system = with python3.pkgs; [ poetry-core ];

  dependencies = with python3.pkgs; [
    beautifulsoup4
    dominate
    html5lib
    httpx
    markdown
    rdflib
  ];

  pyproject = true;
  pythonImportsCheck = [ "pylode" ];
  pythonRelaxDeps = [ "rdflib" ];

  meta = {
    description = "OWL ontology documentation tool using Python and templating, based on LODE";
    homepage = "https://github.com/RDFLib/pyLODE";
    changelog = "https://github.com/RDFLib/pyLODE/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ koslambrou ];
    mainProgram = "pylode";
  };
})
