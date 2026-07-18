{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  importlib-metadata,
  installShellFiles,
  jaraco-classes,
  jaraco-context,
  jaraco-functools,
  jeepney,
  pyfakefs,
  pytestCheckHook,
  pythonOlder,
  secretstorage,
  setuptools-scm,
  shtab,
}:

buildPythonPackage rec {
  pname = "keyring";
  version = "25.7.0";

  src = fetchFromGitHub {
    owner = "jaraco";
    repo = "keyring";
    tag = "v${version}";
    hash = "sha256-v9s28vwx/5DJRa3dQyS/mdZppfvFcfBtafjBRi2c1oQ=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail '"coherent.licensed",' ""
  '';

  nativeBuildInputs = [
    installShellFiles
    shtab
  ];

  nativeCheckInputs = [
    pyfakefs
    pytestCheckHook
  ];

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd keyring \
      --bash <($out/bin/keyring --print-completion bash) \
      --zsh <($out/bin/keyring --print-completion zsh)
  '';

  build-system = [ setuptools-scm ];

  dependencies = [
    jaraco-classes
    jaraco-context
    jaraco-functools
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    jeepney
    secretstorage
  ]
  ++ lib.optionals (pythonOlder "3.12") [ importlib-metadata ];

  disabledTestPaths = [
    "tests/backends/test_macOS.py"
  ]
  # These tests fail when sandboxing is enabled because they are unable to get a password from keychain.
  ++ lib.optional stdenv.hostPlatform.isDarwin "tests/test_multiprocess.py";

  pyproject = true;

  pythonImportsCheck = [
    "keyring"
    "keyring.backend"
  ];

  meta = {
    description = "Store and access your passwords safely";
    homepage = "https://github.com/jaraco/keyring";
    changelog = "https://github.com/jaraco/keyring/blob/${src.tag}/NEWS.rst";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      dotlambda
    ];

    platforms = lib.platforms.unix;
    mainProgram = "keyring";
  };
}
