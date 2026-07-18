{
  lib,
  buildPythonPackage,
  fetchPypi,
  marshmallow,
  requests,
  requests-toolbelt,
  setuptools,
  urllib3,
}:

buildPythonPackage rec {
  pname = "netapp-ontap";
  version = "9.17.1.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-bzDGsKCEH3oszuz4OKnOg7WTMQTnJAGh7POmGhRCyzc=";
    pname = "netapp_ontap";
  };

  postPatch = ''
    substituteInPlace setup.py \
      --replace-fail 'marshmallow>=3.21.3,<4.0.0' 'marshmallow>=3.21.3'
  '';

  # No tests in sdist and no other download available
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    marshmallow
    requests
    requests-toolbelt
    urllib3
  ];

  pyproject = true;
  pythonImportsCheck = [ "netapp_ontap" ];

  meta = {
    description = "Library for working with ONTAP's REST APIs simply in Python";
    homepage = "https://library.netapp.com/ecmdocs/ECMLP3331665/html/index.html";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ SuperSandro2000 ];
    mainProgram = "ontap-cli";
  };
}
