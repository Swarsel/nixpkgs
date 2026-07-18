{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  oldmemo,
  omemo,
  pytest-asyncio,
  pytest-cov-stub,
  pytestCheckHook,
  setuptools,
  slixmpp,
  twomemo,
  typing-extensions,
}:

buildPythonPackage (finalAttrs: {
  pname = "slixmpp-omemo";
  version = "2.2.0";

  src = fetchFromGitHub {
    owner = "Syndace";
    repo = "slixmpp-omemo";
    tag = "v${finalAttrs.version}";
    hash = "sha256-jecnNQu2FNG+d1FzXjLwmbgPi2oDovAAS/MopfY5+Bo=";
  };

  doCheck = true;

  nativeCheckInputs = [
    pytestCheckHook
    pytest-asyncio
    pytest-cov-stub
  ];

  build-system = [ setuptools ];

  dependencies = [
    slixmpp
    omemo
    oldmemo
    twomemo
    typing-extensions
  ]
  ++ oldmemo.optional-dependencies.xml;

  pyproject = true;

  meta = {
    description = "Slixmpp plugin for the Multi-End Message and Object Encryption protocol";
    homepage = "https://github.com/Syndace/slixmpp-omemo";
    changelog = "https://github.com/Syndace/slixmpp-omemo/releases/tag/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ marijanp ];
  };
})
