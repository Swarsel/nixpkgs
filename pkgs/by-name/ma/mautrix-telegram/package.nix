{
  lib,
  fetchFromGitHub,
  fetchPypi,
  python3,
  withE2BE ? true,
}:

let
  tulir-telethon = python3.pkgs.telethon.overrideAttrs (
    finalAttrs: previousAttrs: {
      pname = "tulir_telethon";
      version = "1.99.0a6";

      src = fetchFromGitHub {
        owner = "tulir";
        repo = "Telethon";
        tag = "v${finalAttrs.version}";
        hash = "sha256-ulnA+xKbZDOTzXYmF9oBWNBNhgxSiF+mKx1ijoCyo/w=";
      };

      dontUsePytestCheck = true;
    }
  );
in
python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "mautrix-telegram";
  version = "0.15.3";

  src = fetchFromGitHub {
    owner = "mautrix";
    repo = "telegram";
    tag = "v${finalAttrs.version}";
    hash = "sha256-w3BqWyAJV/lZPoOFDzxhootpw451lYruwM9efwS6cEc=";
  };

  patches = [ ./0001-Re-add-entrypoint.patch ];
  # has no tests
  doCheck = false;
  build-system = with python3.pkgs; [ setuptools ];

  dependencies =
    with python3.pkgs;
    [
      ruamel-yaml
      python-magic
      commonmark
      aiohttp
      yarl
      (mautrix.override { withOlm = withE2BE; })
      tulir-telethon
      asyncpg
      mako
      setuptools
      # speedups
      cryptg
      aiodns
      brotli
      # qr_login
      pillow
      qrcode
      # formattednumbers
      phonenumbers
      # metrics
      prometheus-client
      # sqlite
      aiosqlite
      # proxy support
      pysocks
    ]
    ++ lib.optionals withE2BE [
      # e2be
      python-olm
      pycryptodome
      unpaddedbase64
    ];

  pyproject = true;

  pythonRelaxDeps = [
    "mautrix"
    "ruamel.yaml"
  ];

  meta = {
    description = "Matrix-Telegram hybrid puppeting/relaybot bridge";
    homepage = "https://github.com/mautrix/telegram";
    license = lib.licenses.agpl3Plus;

    maintainers = with lib.maintainers; [
      nyanloutre
      nickcao
    ];

    platforms = lib.platforms.linux;
    mainProgram = "mautrix-telegram";
  };
})
