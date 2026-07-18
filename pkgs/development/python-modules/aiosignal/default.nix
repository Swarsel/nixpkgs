{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  frozenlist,
  pytest-asyncio,
  pytest-cov-stub,
  pytestCheckHook,
  pythonOlder,
  setuptools,
  typing-extensions,
}:

buildPythonPackage rec {
  pname = "aiosignal";
  version = "1.4.0";

  src = fetchFromGitHub {
    owner = "aio-libs";
    repo = "aiosignal";
    tag = "v${version}";
    hash = "sha256-b46/LGoCeL4mhbBPAiPir7otzKKrlKcEFzn8pG/foh0=";
  };

  postPatch = ''
    substituteInPlace setup.cfg \
      --replace "filterwarnings = error" ""
  '';

  nativeCheckInputs = [
    pytest-asyncio
    pytest-cov-stub
    pytestCheckHook
  ];

  build-system = [ setuptools ];
  dependencies = [ frozenlist ] ++ lib.optionals (pythonOlder "3.13") [ typing-extensions ];
  pyproject = true;
  pythonImportsCheck = [ "aiosignal" ];

  meta = {
    description = "Python list of registered asynchronous callbacks";
    homepage = "https://github.com/aio-libs/aiosignal";
    changelog = "https://github.com/aio-libs/aiosignal/blob/v${version}/CHANGES.rst";
    license = with lib.licenses; [ asl20 ];
    maintainers = with lib.maintainers; [ fab ];
  };
}
