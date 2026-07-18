{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  construct,
  paho-mqtt,
  pyserial-asyncio,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "amshan";
  version = "2.1.1";

  src = fetchFromGitHub {
    owner = "toreamun";
    repo = "amshan";
    rev = version;
    hash = "sha256-aw0wTqb2s84STVUN55h6L926pXwaMSppBCfXZVb87w0=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [
    setuptools
  ];

  dependencies = [
    construct
    paho-mqtt
    pyserial-asyncio
  ];

  pyproject = true;
  pythonImportsCheck = [ "han" ];
  # 2021.12.1 is an older version
  passthru.skipBulkUpdate = true;

  meta = {
    description = "Decode smart power meter data stream of Cosem HDLC frames used by MBUS";

    longDescription = ''
      The package has special support of formats for Aidon, Kaifa and Kamstrup
      meters used in Norway and Sweden (AMS HAN).
    '';

    homepage = "https://github.com/toreamun/amshan";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ bjornfor ];
  };
}
