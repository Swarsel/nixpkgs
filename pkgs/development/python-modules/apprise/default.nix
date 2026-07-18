{
  lib,
  stdenv,
  apprise,
  babel,
  buildPythonPackage,
  click,
  cryptography,
  fetchPypi,
  gntp,
  installShellFiles,
  markdown,
  paho-mqtt,
  pytest-mock,
  pytestCheckHook,
  pyyaml,
  requests,
  requests-oauthlib,
  setuptools,
  terminal-notifier,
  testers,
}:

buildPythonPackage (finalAttrs: {
  pname = "apprise";
  version = "1.11.0";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-Ox5vU2WzAtH64nDAyAB5WOVCJLm3gIrOxpAG6if1uKI=";
  };

  postPatch = lib.optionalString stdenv.hostPlatform.isDarwin ''
    substituteInPlace apprise/plugins/macosx.py \
    --replace-fail "/opt/homebrew/bin/terminal-notifier" "${lib.getExe' terminal-notifier "terminal-notifier"}"
  '';

  nativeBuildInputs = [ installShellFiles ];

  nativeCheckInputs = [
    gntp
    paho-mqtt
    pytest-mock
    pytestCheckHook
  ];

  postInstall = ''
    installManPage packaging/man/apprise.1
  '';

  build-system = [
    babel
    setuptools
  ];

  dependencies = [
    click
    cryptography
    markdown
    pyyaml
    requests
    requests-oauthlib
  ];

  pyproject = true;
  pythonImportsCheck = [ "apprise" ];

  passthru = {
    tests.version = testers.testVersion {
      version = "v${finalAttrs.version}";
      package = apprise;
    };
  };

  meta = {
    description = "Push Notifications that work with just about every platform";
    homepage = "https://appriseit.com/";
    changelog = "https://github.com/caronc/apprise/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ getchoo ];
    mainProgram = "apprise";
  };
})
