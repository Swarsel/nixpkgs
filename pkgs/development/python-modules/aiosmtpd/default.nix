{
  lib,
  fetchFromGitHub,
  aiosmtplib,
  atpublic,
  attrs,
  buildPythonPackage,
  # for passthru.tests
  django,
  pytest-mock,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "aiosmtpd";
  version = "1.4.6";

  src = fetchFromGitHub {
    owner = "aio-libs";
    repo = "aiosmtpd";
    tag = "v${version}";
    hash = "sha256-Ih/xbWM9O/fFQiZezydlPlIr36fLRc2lLgdfxD5Jviw=";
  };

  nativeBuildInputs = [ setuptools ];

  propagatedBuildInputs = [
    atpublic
    attrs
  ];

  # Fixes can't be applied easily, https://github.com/aio-libs/aiosmtpd/pull/294
  doCheck = false;

  nativeCheckInputs = [
    pytest-mock
    pytestCheckHook
  ];

  disabledTests = [
    # Requires git
    "test_ge_master"
    # Seems to be a sandbox issue
    "test_byclient"
  ];

  pyproject = true;
  pythonImportsCheck = [ "aiosmtpd" ];

  passthru.tests = {
    inherit django aiosmtplib;
  };

  meta = {
    description = "Asyncio based SMTP server";

    longDescription = ''
      This is a server for SMTP and related protocols, similar in utility to the
      standard library's smtpd.py module.
    '';

    homepage = "https://aiosmtpd.readthedocs.io/";
    changelog = "https://github.com/aio-libs/aiosmtpd/releases/tag/v${version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ eadwu ];
    mainProgram = "aiosmtpd";
  };
}
