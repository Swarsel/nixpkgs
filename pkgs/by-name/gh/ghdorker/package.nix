{
  lib,
  fetchPypi,
  python3,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "ghdorker";
  version = "0.3.2";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-wF4QoXxH55SpdYgKLHf4sCwUk1rkCpSdnIX5FvFi/BU=";
  };

  # Project has no tests
  doCheck = false;

  build-system = with python3.pkgs; [
    setuptools
  ];

  dependencies = with python3.pkgs; [
    ghapi
    glom
    python-dotenv
    pyyaml
  ];

  pyproject = true;

  pythonImportsCheck = [
    "GHDorker"
  ];

  meta = {
    description = "Extensible GitHub dorking tool";
    homepage = "https://github.com/dtaivpp/ghdorker";
    license = with lib.licenses; [ asl20 ];
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "ghdorker";
  };
})
