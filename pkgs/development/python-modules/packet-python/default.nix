{
  lib,
  buildPythonPackage,
  fetchPypi,
  pytestCheckHook,
  requests,
  requests-mock,
  setuptools,
}:

buildPythonPackage rec {
  pname = "packet-python";
  version = "1.44.3";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-WVfMELOoml7Hx78jy6TAwlFRLuSQu9dtsb6Khs6/cgI=";
  };

  postPatch = ''
    substituteInPlace setup.py \
      --replace-fail "pytest-runner" ""
  '';

  nativeCheckInputs = [
    pytestCheckHook
    requests-mock
  ];

  build-system = [ setuptools ];
  dependencies = [ requests ];
  pyproject = true;
  pythonImportsCheck = [ "packet" ];

  meta = {
    description = "Python client for the Packet API";
    homepage = "https://github.com/packethost/packet-python";
    changelog = "https://github.com/packethost/packet-python/blob/v${version}/CHANGELOG.md";
    license = lib.licenses.lgpl3Only;
    maintainers = with lib.maintainers; [ dipinhora ];
  };
}
