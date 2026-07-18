{
  lib,
  buildPythonPackage,
  fetchPypi,
  keyring,
  poetry-core,
  requests,
}:

buildPythonPackage rec {
  pname = "deepl";
  version = "1.27.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-jYOlPZWP+pY4j17NZCWp2dkxFEwWwFx6hOzrmhRUu5I=";
  };

  nativeBuildInputs = [ poetry-core ];

  propagatedBuildInputs = [
    requests
    keyring
  ];

  # Requires internet access and an API key
  doCheck = false;
  pyproject = true;
  pythonImportsCheck = [ "deepl" ];

  meta = {
    description = "Language translation API that allows other computer programs to send texts and documents to DeepL's servers and receive high-quality translations";
    homepage = "https://github.com/DeepLcom/deepl-python";
    changelog = "https://github.com/DeepLcom/deepl-python/blob/v${version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ MaskedBelgian ];
    mainProgram = "deepl";
  };
}
