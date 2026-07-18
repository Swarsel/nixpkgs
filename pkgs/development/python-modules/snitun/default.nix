{
  lib,
  stdenv,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  cryptography,
  pytest-aiohttp,
  pytest-codspeed,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "snitun";
  version = "0.45.1";

  src = fetchFromGitHub {
    owner = "NabuCasa";
    repo = "snitun";
    tag = version;
    hash = "sha256-luXv5J0PUvW+AGTecwkEq+qkG1N5Ja5NbBKJ3M6HC0I=";
  };

  patches = [
    # https://github.com/NabuCasa/snitun/pull/459
    ./fix-python-3.14-compatibility.diff
  ];

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail 'version = "0.0.0"' 'version = "${version}"'
  '';

  nativeCheckInputs = [
    pytest-aiohttp
    pytest-codspeed
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    aiohttp
    cryptography
  ];

  disabledTests = lib.optionals stdenv.hostPlatform.isDarwin [
    "test_multiplexer_data_channel_abort_full" # https://github.com/NabuCasa/snitun/issues/61
    # port binding conflicts
    "test_snitun_single_runner_timeout"
    "test_snitun_single_runner_throttling"
    # ConnectionResetError: [Errno 54] Connection reset by peer
    "test_peer_listener_timeout"
  ];

  pyproject = true;
  pythonImportsCheck = [ "snitun" ];

  meta = {
    description = "SNI proxy with TCP multiplexer";
    homepage = "https://github.com/nabucasa/snitun";
    changelog = "https://github.com/NabuCasa/snitun/releases/tag/${src.tag}";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ Scriptkiddi ];
    platforms = lib.platforms.linux;
  };
}
