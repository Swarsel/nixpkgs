{
  lib,
  fetchFromGitHub,
  aiohttp,
  aiosqlite,
  asyncpg,
  attrs,
  # optional deps
  base58,
  buildPythonPackage,
  pycryptodome,
  pytest-asyncio,
  # check deps
  pytestCheckHook,
  python-magic,
  python-olm,
  ruamel-yaml,
  # deps
  setuptools,
  unpaddedbase64,
  yarl,
  withOlm ? false,
}:

buildPythonPackage rec {
  pname = "mautrix";
  version = "0.21.0";

  src = fetchFromGitHub {
    owner = "mautrix";
    repo = "python";
    tag = "v${version}";
    hash = "sha256-4nEjKIWzXd0e/cLL4py9SS+/YIcGHq2f+cCTEY2ENmE=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-asyncio
    aiosqlite
    asyncpg
    ruamel-yaml
  ];

  build-system = [ setuptools ];

  dependencies = [
    aiohttp
    attrs
    yarl
  ]
  ++ lib.optionals withOlm optional-dependencies.encryption;

  disabledTestPaths = lib.optionals (!withOlm) [ "mautrix/crypto/" ];

  optional-dependencies = {
    detect_mimetype = [ python-magic ];

    encryption = [
      base58
      python-olm
      unpaddedbase64
      pycryptodome
    ];
  };

  pyproject = true;
  pythonImportsCheck = [ "mautrix" ];

  meta = {
    description = "Asyncio Matrix framework";
    homepage = "https://github.com/tulir/mautrix-python";
    changelog = "https://github.com/mautrix/python/releases/tag/${src.tag}";
    license = lib.licenses.mpl20;

    maintainers = with lib.maintainers; [
      nyanloutre
      sumnerevans
      nickcao
    ];
  };
}
