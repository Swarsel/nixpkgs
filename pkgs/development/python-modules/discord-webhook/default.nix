{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  httpx,
  nix-update-script,
  poetry-core,
  pytestCheckHook,
  requests,
}:

buildPythonPackage rec {
  pname = "discord-webhook";
  version = "1.4.1";

  src = fetchFromGitHub {
    owner = "lovvskillz";
    repo = "python-discord-webhook";
    tag = version;
    hash = "sha256-7nVvtXo1XjQExZSCF9VaYSCeEByJY2jn5KbVGTi33f0=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ poetry-core ];

  dependencies = [
    requests
    httpx # Optional, required for async support.
  ];

  pyproject = true;

  pythonImportsCheck = [
    "discord_webhook"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Execute discord webhooks";
    homepage = "https://github.com/lovvskillz/python-discord-webhook";
    changelog = "https://github.com/lovvskillz/python-discord-webhook/blob/${version}/CHANGES.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ polyfloyd ];
  };
}
