{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  poetry-core,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "telegram-text";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "SKY-ALIN";
    repo = "telegram-text";
    tag = "v${version}";
    hash = "sha256-eUy4kyCmM/5Ag/0s9hYW2IIg+OTX2L7EsoOYivhd0pU=";
  };

  nativeBuildInputs = [ poetry-core ];
  nativeCheckInputs = [ pytestCheckHook ];
  pyproject = true;

  meta = {
    description = "Python markup module for Telegram messenger";
    homepage = "https://telegram-text.alinsky.tech/";
    changelog = "https://github.com/SKY-ALIN/telegram-text/blob/v${version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ sikmir ];
    downloadPage = "https://github.com/SKY-ALIN/telegram-text";
  };
}
