{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  requests,
  setuptools,
  websocket-client,
  zeroconf,
}:

buildPythonPackage rec {
  pname = "libsoundtouch";
  version = "0.8.0";

  src = fetchFromGitHub {
    owner = "CharlesBlonde";
    repo = "libsoundtouch";
    tag = version;
    hash = "sha256-am8nHPdtKMh8ZA/jKgz2jnltpvgEga8/BjvP5nrhgvI=";
  };

  postPatch = ''
    substituteInPlace setup.py \
      --replace-fail "'enum-compat>=0.0.2'," ""
  '';

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];

  dependencies = [
    requests
    websocket-client
    zeroconf
  ];

  disabledTests = [
    # mock data order mismatch
    "test_select_content_item"
    "test_snapshot_restore"
  ];

  pyproject = true;
  pythonImportsCheck = [ "libsoundtouch" ];

  meta = {
    description = "Bose Soundtouch Python library";
    homepage = "https://github.com/CharlesBlonde/libsoundtouch";
    license = lib.licenses.asl20;
    maintainers = [ ];
  };
}
