{
  lib,
  fetchFromGitHub,
  attrs,
  buildPythonPackage,
  deprecated,
  hatchling,
  pytest-mock,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "headerparser";
  version = "0.5.2";

  src = fetchFromGitHub {
    owner = "jwodder";
    repo = "headerparser";
    tag = "v${version}";
    hash = "sha256-fn9Nlazte6r5JMmp9ynq0qmkLEoJGv8witgZlD7zJNM=";
  };

  nativeCheckInputs = [
    pytest-mock
    pytestCheckHook
  ];

  build-system = [ hatchling ];

  dependencies = [
    attrs
    deprecated
  ];

  pyproject = true;
  pythonImportsCheck = [ "headerparser" ];

  meta = {
    description = "Module to parse key-value pairs in the style of RFC 822 (e-mail) headers";
    homepage = "https://github.com/jwodder/headerparser";
    changelog = "https://github.com/wheelodex/headerparser/blob/v${version}/CHANGELOG.md";
    license = with lib.licenses; [ mit ];
    maintainers = with lib.maintainers; [ ayazhafiz ];
  };
}
