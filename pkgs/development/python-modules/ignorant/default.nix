{
  lib,
  beautifulsoup4,
  buildPythonPackage,
  fetchPypi,
  httpx,
  setuptools,
  termcolor,
  tqdm,
  trio,
}:

buildPythonPackage rec {
  pname = "ignorant";
  version = "1.2";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-SLjED08uI+RjX+E0WHTQceReTEaY9WLPhXR3n0fP080=";
  };

  # Module has no tests
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    beautifulsoup4
    httpx
    termcolor
    tqdm
    trio
  ];

  pyproject = true;
  pythonImportsCheck = [ "ignorant" ];

  pythonRemoveDeps = [
    # https://github.com/megadose/ignorant/pull/37
    "argparse"
    # https://github.com/megadose/ignorant/pull/36
    "bs4"
  ];

  meta = {
    description = "Module to check if a phone number is used on different sites";
    homepage = "https://pypi.org/project/ignorant/";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ fab ];
  };
}
