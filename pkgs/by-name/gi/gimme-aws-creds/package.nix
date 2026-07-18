{
  lib,
  fetchFromGitHub,
  gimme-aws-creds,
  installShellFiles,
  nix-update-script,
  python3,
  testers,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "gimme-aws-creds";
  version = "2.8.2"; # N.B: if you change this, check if overrides are still up-to-date

  src = fetchFromGitHub {
    owner = "Nike-Inc";
    repo = "gimme-aws-creds";
    rev = "v${finalAttrs.version}";
    hash = "sha256-fsFYcfbLeYV6tpOGgNrFmYjcUAmdsx5zwUbvcctwFVs=";
  };

  nativeBuildInputs = [
    installShellFiles
  ];

  nativeCheckInputs = with python3.pkgs; [
    pytestCheckHook
    responses
  ];

  preCheck = ''
    # Disable using platform's keyring unavailable in sandbox
    export PYTHON_KEYRING_BACKEND="keyring.backends.fail.Keyring"
  '';

  postInstall = ''
    rm $out/bin/gimme-aws-creds.cmd
    chmod +x $out/bin/gimme-aws-creds
    installShellCompletion --bash --name gimme-aws-creds $out/bin/gimme-aws-creds-autocomplete.sh
    rm $out/bin/gimme-aws-creds-autocomplete.sh
  '';

  dependencies = with python3.pkgs; [
    boto3
    beautifulsoup4
    ctap-keyring-device
    requests
    okta
    pyjwt
    html5lib
    furl
  ];

  disabledTests = [
    "test_build_factor_name_webauthn_registered"
  ];

  format = "setuptools";

  pythonImportsCheck = [
    "gimme_aws_creds"
  ];

  pythonRemoveDeps = [
    "configparser"
  ];

  passthru = {
    tests.version = testers.testVersion {
      version = "gimme-aws-creds ${finalAttrs.version}";
      command = ''touch tmp.conf && OKTA_CONFIG="tmp.conf" gimme-aws-creds --version'';
      package = gimme-aws-creds;
    };

    updateScript = nix-update-script { };
  };

  meta = {
    description = "CLI that utilizes Okta IdP via SAML to acquire temporary AWS credentials";
    homepage = "https://github.com/Nike-Inc/gimme-aws-creds";
    changelog = "https://github.com/Nike-Inc/gimme-aws-creds/releases";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ jbgosselin ];
    mainProgram = "gimme-aws-creds";
  };
})
