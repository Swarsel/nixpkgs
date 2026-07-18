{
  lib,
  buildPythonPackage,
  cryptg,
  fetchFromCodeberg,
  openssl,
  pyaes,
  pytest-asyncio,
  pytestCheckHook,
  pythonAtLeast,
  rsa,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "telethon";
  version = "1.42.0";

  src = fetchFromCodeberg {
    owner = "Lonami";
    repo = "Telethon";
    tag = "v${finalAttrs.version}";
    hash = "sha256-NMHJkSTGR3/tck0k97EfVN9f85PAWst+EZ6G7Tgrt5s=";
  };

  postPatch = ''
    substituteInPlace telethon/crypto/libssl.py --replace-fail \
      "ctypes.util.find_library('ssl')" "'${lib.getLib openssl}/lib/libssl.so'"
  '';

  nativeCheckInputs = [
    pytest-asyncio
    pytestCheckHook
  ]
  ++ lib.concatAttrValues finalAttrs.passthru.optional-dependencies;

  build-system = [
    setuptools
  ];

  dependencies = [
    pyaes
    rsa
  ];

  disabled = pythonAtLeast "3.14";

  optional-dependencies = {
    cryptg = [ cryptg ];
  };

  pyproject = true;

  meta = {
    description = "Full-featured Telegram client library for Python 3";
    homepage = "https://codeberg.org/Lonami/Telethon";
    changelog = "https://codeberg.org/Lonami/Telethon/blob/${finalAttrs.src.tag}/readthedocs/misc/changelog.rst";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ nyanloutre ];
  };
})
