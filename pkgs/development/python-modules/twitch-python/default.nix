{
  lib,
  buildPythonPackage,
  fetchPypi,
  isPy3k,
  pytestCheckHook,
  requests,
  responses,
  rx,
  setuptools,
}:

buildPythonPackage rec {
  pname = "twitch-python";
  version = "0.0.20";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-bgnXIQuOCrtoknZ9ciB56zWxTCnncM2032TVaey6oXw=";
  };

  postPatch = ''
    substituteInPlace setup.py --replace-fail "'pipenv'," ""
  '';

  nativeCheckInputs = [
    pytestCheckHook
    responses
  ];

  build-system = [ setuptools ];

  dependencies = [
    requests
    rx
  ];

  disabled = !isPy3k;
  pyproject = true;
  pythonImportsCheck = [ "twitch" ];

  meta = {
    description = "Twitch module for Python";
    homepage = "https://github.com/PetterKraabol/Twitch-Python";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
