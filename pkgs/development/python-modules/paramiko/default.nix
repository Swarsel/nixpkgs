{
  lib,
  fetchFromGitHub,
  bcrypt,
  buildPythonPackage,
  cryptography,
  icecream,
  invoke,
  pynacl,
  pytest-relaxed,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "paramiko";
  version = "5.0.0";

  src = fetchFromGitHub {
    owner = "paramiko";
    repo = "paramiko";
    tag = finalAttrs.version;
    hash = "sha256-zzbM2oGaZ5jkIN7LyDGuMAKSpSmUwpBbup6MBVdTaXA=";
  };

  nativeCheckInputs = [
    icecream
    pytestCheckHook
    pytest-relaxed
  ];

  __darwinAllowLocalNetworking = true;
  build-system = [ setuptools ];

  dependencies = [
    bcrypt
    cryptography
    invoke
    pynacl
  ];

  pyproject = true;
  pythonImportsCheck = [ "paramiko" ];

  meta = {
    description = "Native Python SSHv2 protocol library";

    longDescription = ''
      Library for making SSH2 connections (client or server). Emphasis is
      on using SSH2 as an alternative to SSL for making secure connections
      between python scripts. All major ciphers and hash methods are
      supported. SFTP client and server mode are both supported too.
    '';

    homepage = "https://github.com/paramiko/paramiko/";
    changelog = "https://github.com/paramiko/paramiko/blob/${finalAttrs.src.tag}/sites/www/changelog.rst";
    license = lib.licenses.lgpl21Plus;
  };
})
