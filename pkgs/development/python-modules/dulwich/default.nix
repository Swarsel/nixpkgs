{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cargo,
  fastimport,
  gevent,
  geventhttpclient,
  git,
  glibcLocales,
  gnupg,
  gpg,
  merge3,
  nix-update-script,
  openssh,
  paramiko,
  pytestCheckHook,
  rich,
  rustPlatform,
  rustc,
  setuptools,
  setuptools-rust,
  urllib3,
}:

buildPythonPackage (finalAttrs: {
  pname = "dulwich";
  version = "1.2.6";

  src = fetchFromGitHub {
    owner = "jelmer";
    repo = "dulwich";
    tag = "dulwich-${finalAttrs.version}";
    hash = "sha256-nj20g5OmlcqWDaKv3NoKWZS5/e4HOMCf7DHeS7xDzjQ=";
  };

  nativeBuildInputs = [
    rustPlatform.cargoSetupHook
    cargo
    rustc
  ];

  nativeCheckInputs = [
    gevent
    geventhttpclient
    git
    glibcLocales
    openssh # for ssh-keygen
    pytestCheckHook
  ]
  ++ lib.concatAttrValues finalAttrs.passthru.optional-dependencies;

  preCheck = ''
    export TMPDIR=$(mktemp -d)
  '';

  __darwinAllowLocalNetworking = true;

  build-system = [
    setuptools
    setuptools-rust
  ];

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) pname version src;
    hash = "sha256-wifh/beg3VVQpAXg/P/tq6qiUwCqXxhWPoRvX2HcFOc=";
  };

  dependencies = [
    urllib3
  ];

  disabledTestPaths = [
    # AssertionError: GPGMEError not raised
    "tests/test_signature.py::GPGSignatureVendorTests::test_verify_invalid_signature"
  ];

  disabledTests = [
    # Depends on setuid which is not available in sandboxed environments
    "SharedRepositoryTests"
  ];

  enabledTestPaths = [ "tests" ];

  optional-dependencies = {
    colordiff = [ rich ];
    fastimport = [ fastimport ];
    https = [ urllib3 ];
    merge = [ merge3 ];
    paramiko = [ paramiko ];

    pgp = [
      gpg
      gnupg
    ];
  };

  pyproject = true;
  pythonImportsCheck = [ "dulwich" ];

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version-regex"
      "^dulwich-([1-9][0-9.]+)$"
    ];
  };

  meta = {
    description = "Implementation of the Git file formats and protocols";

    longDescription = ''
      Dulwich is a Python implementation of the Git file formats and protocols, which
      does not depend on Git itself. All functionality is available in pure Python.
    '';

    homepage = "https://www.dulwich.io/";
    changelog = "https://github.com/jelmer/dulwich/blob/dulwich-${finalAttrs.src.tag}/NEWS";

    license = with lib.licenses; [
      asl20
      gpl2Plus
    ];

    maintainers = with lib.maintainers; [
      koral
      sarahec
    ];
  };
})
