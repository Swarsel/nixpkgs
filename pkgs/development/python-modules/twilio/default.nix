{
  lib,
  fetchFromGitHub,
  aiohttp,
  aiohttp-retry,
  buildPythonPackage,
  cryptography,
  django,
  mock,
  multidict,
  pyjwt,
  pyngrok,
  pytestCheckHook,
  pytz,
  requests,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "twilio";
  version = "9.10.9";

  src = fetchFromGitHub {
    owner = "twilio";
    repo = "twilio-python";
    tag = finalAttrs.version;
    hash = "sha256-CQWP8QujDvV5+Z5JDUcWhQ4mJZqaXnxpScS9sBxIX4Q=";
  };

  # https://github.com/twilio/twilio-python/pull/919
  patches = [ ./remove-aiounittest.patch ];

  nativeCheckInputs = [
    cryptography
    django
    mock
    multidict
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    aiohttp
    aiohttp-retry
    pyjwt
    pyngrok
    pytz
    requests
  ];

  disabledTestPaths = [
    # Tests require API token
    "tests/cluster/test_webhook.py"
    "tests/cluster/test_cluster.py"
  ];

  disabledTests = [
    # Tests require network access
    "test_set_default_user_agent"
    "test_set_user_agent_extensions"
  ];

  pyproject = true;
  pythonImportsCheck = [ "twilio" ];

  meta = {
    description = "Twilio API client and TwiML generator";
    homepage = "https://github.com/twilio/twilio-python/";
    changelog = "https://github.com/twilio/twilio-python/blob/${finalAttrs.src.tag}/CHANGES.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
})
