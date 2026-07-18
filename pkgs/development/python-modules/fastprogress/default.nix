{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  fastcore,
  fasthtml,
  ipython,
  numpy,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "fastprogress";
  version = "1.1.6";

  src = fetchFromGitHub {
    owner = "fastai";
    repo = "fastprogress";
    tag = finalAttrs.version;
    hash = "sha256-KQ8CYS+SSTve905k695w3TjCFBdWxGR3PqDsYTV8b4k=";
  };

  # no real tests
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    fastcore
    numpy
    fasthtml
    ipython
  ];

  pyproject = true;
  pythonImportsCheck = [ "fastprogress" ];

  meta = {
    description = "Simple and flexible progress bar for Jupyter Notebook and console";
    homepage = "https://github.com/fastai/fastprogress";
    changelog = "https://github.com/AnswerDotAI/fastprogress/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ ris ];
  };
})
