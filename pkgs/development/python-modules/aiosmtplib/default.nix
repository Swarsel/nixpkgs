{
  lib,
  fetchFromGitHub,
  aiosmtpd,
  buildPythonPackage,
  hatchling,
  hypothesis,
  pytest-asyncio_0,
  pytestCheckHook,
  trustme,
}:

buildPythonPackage (finalAttrs: {
  pname = "aiosmtplib";
  version = "5.1.2";

  src = fetchFromGitHub {
    owner = "cole";
    repo = "aiosmtplib";
    tag = "v${finalAttrs.version}";
    hash = "sha256-IAWMs4LBfVDMLxgPBnXrHQQ/8yhBYjvd4Fi4k0F19o0=";
  };

  nativeCheckInputs = [
    aiosmtpd
    hypothesis
    pytest-asyncio_0
    pytestCheckHook
    trustme
  ];

  build-system = [ hatchling ];
  pyproject = true;
  pythonImportsCheck = [ "aiosmtplib" ];

  meta = {
    description = "Module which provides a SMTP client";
    homepage = "https://github.com/cole/aiosmtplib";
    changelog = "https://github.com/cole/aiosmtplib/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
})
