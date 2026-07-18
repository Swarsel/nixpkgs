{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  docopt,
  freezegun,
  mock,
  pyjwt,
  pytest-mock,
  pytestCheckHook,
  requests,
  requests-mock,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "notifications-python-client";
  version = "12.1.0";

  src = fetchFromGitHub {
    owner = "alphagov";
    repo = "notifications-python-client";
    tag = finalAttrs.version;
    hash = "sha256-jaNALtQQBxBE2ofBw9ZXC4z5VCnclAAHYvPMTBK74tY=";
  };

  postPatch = ''
    substituteInPlace setup.py \
      --replace-fail "pytest-runner" ""
  '';

  nativeCheckInputs = [
    freezegun
    mock
    pytest-mock
    pytestCheckHook
    requests-mock
  ];

  build-system = [ setuptools ];

  dependencies = [
    docopt
    pyjwt
    requests
  ];

  pyproject = true;
  pythonImportsCheck = [ "notifications_python_client" ];

  meta = {
    description = "Python client for the GOV.UK Notify API";
    homepage = "https://github.com/alphagov/notifications-python-client";
    changelog = "https://github.com/alphagov/notifications-python-client/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
})
