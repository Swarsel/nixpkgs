{
  lib,
  buildPythonPackage,
  fetchPypi,
  # dependencies
  gradio-client,
  # build-system
  hatchling,
  typer,
}:

buildPythonPackage (finalAttrs: {
  pname = "hf-gradio";
  version = "0.4.1";

  # No tags on GitHub
  # https://github.com/gradio-app/hf-gradio/issues/2
  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-oBfZQmGPDUlaWO5FYwR/oEvvYUwA4Mt4mpptBjPP+ns=";
    pname = "hf_gradio";
  };

  # The PyPI sdist ships no test suite.
  doCheck = false;
  __structuredAttrs = true;

  build-system = [
    hatchling
  ];

  dependencies = [
    gradio-client
    typer
  ];

  pyproject = true;
  pythonImportsCheck = [ "hf_gradio" ];

  meta = {
    description = "Extension of the Hugging Face CLI for interacting with Gradio Spaces and Apps";
    homepage = "https://pypi.org/project/hf-gradio";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ GaetanLepage ];
  };
})
