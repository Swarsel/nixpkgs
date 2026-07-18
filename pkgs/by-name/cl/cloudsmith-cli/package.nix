{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "cloudsmith-cli";
  version = "1.9.4";

  src = fetchFromGitHub {
    owner = "cloudsmith-io";
    repo = "cloudsmith-cli";
    tag = "v${finalAttrs.version}";
    hash = "sha256-VfP7Bu8+F1bHiwceI9s+vHq76wEkG6+hJZe5jZgVm90=";
  };

  postPatch = ''
    # Fix compatibility with urllib3 >= 2.0 - method_whitelist renamed to allowed_methods
    # https://github.com/cloudsmith-io/cloudsmith-cli/pull/148
    substituteInPlace cloudsmith_cli/core/rest.py \
      --replace-fail 'method_whitelist=False' 'allowed_methods=False'
    substituteInPlace setup.py \
      --replace-fail 'urllib3<2.0' 'urllib3'
  '';

  nativeCheckInputs = with python3Packages; [
    pytestCheckHook
    pytest-cov-stub
    freezegun
    httpretty
  ];

  preCheck = ''
    # When test_implicit_retry_for_status_codes calls initialise_api(),
    # and no user strings like LOGNAME or USER is set, getpass will call
    # getpwuid() which will then fail when we enable auto-allocate-uids.
    export USER=nixbld
    # https://github.com/NixOS/nixpkgs/issues/255262
    cd "$out"
  '';

  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [
    click
    click-configfile
    click-didyoumean
    click-spinner
    cloudsmith-api
    keyring
    requests
    requests-toolbelt
    semver
    urllib3
  ];

  disabledTests = [
    "TestMainCommand"
  ];

  pyproject = true;

  pythonImportsCheck = [
    "cloudsmith_cli"
  ];

  meta = {
    description = "Cloudsmith Command Line Interface";
    homepage = "https://help.cloudsmith.io/docs/cli/";
    changelog = "https://github.com/cloudsmith-io/cloudsmith-cli/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ usertam ];
    platforms = lib.platforms.unix;
    mainProgram = "cloudsmith";
  };
})
