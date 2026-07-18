{
  lib,
  fetchFromGitHub,
  boto3,
  buildPythonPackage,
  comet-ml,
  ipython,
  matplotlib,
  numpy,
  reportlab,
  requests,
  scipy,
  selenium,
  setuptools,
  streamlit,
  tqdm,
  urllib3,
  zipfile2,
}:

buildPythonPackage rec {
  pname = "cometx";
  version = "3.6.6";

  src = fetchFromGitHub {
    owner = "comet-ml";
    repo = "cometx";
    tag = version;
    hash = "sha256-Ub7Ucn/Xgaedymqjgiouy685PPr3tULAvJNLeqAgf78=";
  };

  # WARNING: Running the tests will create experiments, models, assets, etc.
  # on your Comet account.
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    comet-ml
    ipython
    matplotlib
    numpy
    requests
    scipy
    selenium
    urllib3
    zipfile2
    tqdm
    reportlab
    streamlit
    boto3
  ];

  pyproject = true;
  pythonImportsCheck = [ "cometx" ];

  meta = {
    description = "Open source extensions for the Comet SDK";
    homepage = "https://github.com/comet-ml/comet-sdk-extensions/";
    changelog = "https://github.com/comet-ml/cometx/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ jherland ];
    mainProgram = "cometx";
  };
}
