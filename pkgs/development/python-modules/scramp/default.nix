{
  lib,
  asn1crypto,
  buildPythonPackage,
  fetchFromCodeberg,
  hatchling,
  pytest-mock,
  pytestCheckHook,
  versioningit,
}:

buildPythonPackage rec {
  pname = "scramp";
  version = "1.4.5";

  src = fetchFromCodeberg {
    owner = "tlocke";
    repo = "scramp";
    rev = version;
    hash = "sha256-KpododRJ+CYRGBR7Sr5cVBhJvUwh9YmPERd/DAJqEcY=";
  };

  postPatch = ''
    # Upstream uses versioningit to set the version
    sed -i "/versioningit >=/d" pyproject.toml
    sed -i '/^name =.*/a version = "${version}"' pyproject.toml
    sed -i "/dynamic =/d" pyproject.toml
  '';

  nativeCheckInputs = [
    pytest-mock
    pytestCheckHook
  ];

  build-system = [
    hatchling
    versioningit
  ];

  dependencies = [ asn1crypto ];
  disabledTests = [ "test_readme" ];
  pyproject = true;
  pythonImportsCheck = [ "scramp" ];

  meta = {
    description = "Implementation of the SCRAM authentication protocol";
    homepage = "https://github.com/tlocke/scramp";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
