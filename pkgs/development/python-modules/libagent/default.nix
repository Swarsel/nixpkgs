{
  lib,
  fetchFromGitHub,
  backports-shutil-which,
  bech32,
  buildPythonPackage,
  configargparse,
  cryptography,
  docutils,
  ecdsa,
  gnupg,
  mnemonic,
  mock,
  nix-update-script,
  pinentry-curses,
  pymsgbox,
  pynacl,
  pytestCheckHook,
  python-daemon,
  semver,
  setuptools,
  unidecode,
}:

# When changing this package, please test packages {onlykey,trezor}-agent

buildPythonPackage (finalAttrs: {
  pname = "libagent";
  version = "0.16.1";

  src = fetchFromGitHub {
    owner = "romanz";
    repo = "trezor-agent";
    tag = "libagent/${finalAttrs.version}";
    hash = "sha256-JFHBE2o5VSJaz5yeCiXmBchm4/1gA+dZ/PRt3+WENdA=";
  };

  # hardcode the path to gpgconf and pinentry in the libagent library
  postPatch = ''
    substituteInPlace libagent/gpg/keyring.py \
      --replace "util.which('gpgconf')" "'${gnupg}/bin/gpgconf'" \
      --replace "'gpg-connect-agent'" "'${gnupg}/bin/gpg-connect-agent'" \
      --replace "get_gnupg_components(sp=sp)['pinentry']" "'${(lib.getExe pinentry-curses)}'"
  '';

  nativeCheckInputs = [
    mock
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    backports-shutil-which
    unidecode
    configargparse
    python-daemon
    pymsgbox
    ecdsa
    docutils
    mnemonic
    semver
    pynacl
    bech32
    cryptography
  ];

  disabledTests = [
    # test fails in sandbox
    "test_get_agent_sock_path"
  ];

  pyproject = true;
  pythonImportsCheck = [ "libagent" ];
  # https://github.com/romanz/trezor-agent/pull/481
  pythonRemoveDeps = [ "backports.shutil-which" ];

  passthru.updateScript = nix-update-script {
    extraArgs = [ "--version-regex=libagent/(.*)" ];
  };

  meta = {
    description = "Using hardware wallets as SSH/GPG agent";
    homepage = "https://github.com/romanz/trezor-agent";
    license = lib.licenses.lgpl3Only;
    maintainers = with lib.maintainers; [ np ];
  };
})
