{
  lib,
  fetchFromGitHub,
  cacert,
  git,
  git-lfs,
  python3Packages,
  versionCheckHook,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "github-backup";
  version = "0.64.0";

  src = fetchFromGitHub {
    owner = "josegonzalez";
    repo = "python-github-backup";
    tag = finalAttrs.version;
    hash = "sha256-UPHwohx2qN/vT5a1Km0UqW2SB7br6yAZJ1xKYKX4H70=";
  };

  env.SSL_CERT_FILE = "${cacert}/etc/ssl/certs/ca-bundle.crt";

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  build-system = with python3Packages; [
    setuptools
  ];

  makeWrapperArgs = [
    "--prefix"
    "PATH"
    ":"
    (lib.makeBinPath [
      git
      git-lfs
    ])
  ];

  pyproject = true;
  versionCheckKeepEnvironment = [ "SSL_CERT_FILE" ];

  meta = {
    description = "Backup a github user or organization";
    homepage = "https://github.com/josegonzalez/python-github-backup";
    changelog = "https://github.com/josegonzalez/python-github-backup/blob/${finalAttrs.src.tag}/CHANGES.rst";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
    mainProgram = "github-backup";
  };
})
