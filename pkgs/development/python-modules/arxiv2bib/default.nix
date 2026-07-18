{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  mock,
  setuptools,
  unittestCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "arxiv2bib";
  version = "1.0.8";

  # Missing tests on Pypi
  src = fetchFromGitHub {
    owner = "nathangrigg";
    repo = "arxiv2bib";
    tag = finalAttrs.version;
    hash = "sha256-b8HMerITPGY9bjRIeJzpPKiBHH+uPEx2S+xSILqP4s4=";
  };

  nativeCheckInputs = [
    unittestCheckHook
    mock
  ];

  __structuredAttrs = true;
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "arxiv2bib" ];

  unittestFlagsArray = [
    "-s"
    "tests"
  ];

  meta = {
    description = "Get a BibTeX entry from an arXiv id number, using the arxiv.org API";
    homepage = "http://nathangrigg.github.io/arxiv2bib/";
    license = lib.licenses.bsd3;
    maintainers = [ lib.maintainers.nico202 ];
    mainProgram = "arxiv2bib";
  };
})
