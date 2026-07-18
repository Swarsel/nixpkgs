{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  gradio,
  gradio-client,
  hatch-fancy-pypi-readme,
  hatch-requirements-txt,
  hatchling,
}:

buildPythonPackage {
  pname = "gradio-pdf";
  version = "0.0.23";

  src = fetchFromGitHub {
    owner = "freddyaboulton";
    repo = "gradio-pdf";
    # No source release on Pypi
    # No tags on GitHub
    rev = "57deb0bd2823a9a75c5da498cc39a85f8fd4ff02";
    hash = "sha256-FzO8jKZw4EBqmsQ0xXqj0lqSHXxKk+rZjuluyNJVPYk=";
  };

  buildInputs = [ gradio.sans-reverse-dependencies ];
  # tested in `gradio`
  doCheck = false;

  build-system = [
    hatch-fancy-pypi-readme
    hatch-requirements-txt
    hatchling
  ];

  dependencies = [ gradio-client ];
  disallowedReferences = [ gradio.sans-reverse-dependencies ];
  pyproject = true;
  pythonImportsCheck = [ "gradio_pdf" ];

  meta = {
    description = "Python library for easily interacting with trained machine learning models";
    homepage = "https://pypi.org/project/gradio-pdf/";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ pbsds ];
  };
}
