{
  lib,
  buildPythonPackage,
  fetchPypi,
  python-dateutil,
  ruamel-yaml,
}:

buildPythonPackage rec {
  pname = "strictyaml";
  version = "1.7.3";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-IvhUpfyrQrXduoAwoOS+UcqJrwJnlhyNbPqGOVWGxAc=";
  };

  postPatch = ''
    substituteInPlace setup.py \
      --replace "ruamel.yaml==0.17.4" "ruamel.yaml"
  '';

  propagatedBuildInputs = [
    ruamel-yaml
    python-dateutil
  ];

  # Library tested with external tool
  # https://hitchdev.com/approach/contributing-to-hitch-libraries/
  doCheck = false;
  format = "setuptools";
  pythonImportsCheck = [ "strictyaml" ];

  meta = {
    description = "Strict, typed YAML parser";
    homepage = "https://hitchdev.com/strictyaml/";
    changelog = "https://hitchdev.com/strictyaml/changelog/";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
