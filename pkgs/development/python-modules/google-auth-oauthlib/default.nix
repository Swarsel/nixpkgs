{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  click,
  google-auth,
  nix-update-script,
  pytestCheckHook,
  requests-oauthlib,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "google-auth-oauthlib";
  version = "1.4.0";

  src = fetchFromGitHub {
    owner = "googleapis";
    repo = "google-cloud-python";
    tag = "google-auth-oauthlib-v${finalAttrs.version}";
    hash = "sha256-KJviH4dofYSvZu9S7VMBSnGjH66xMUEvhcmZN7GJ4Iw=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ]
  ++ lib.flatten (builtins.attrValues finalAttrs.passthru.optional-dependencies);

  __darwinAllowLocalNetworking = true;
  build-system = [ setuptools ];

  dependencies = [
    google-auth
    requests-oauthlib
  ];

  disabledTests = [
    # Flaky test. See https://github.com/NixOS/nixpkgs/issues/288424#issuecomment-1941609973.
    "test_run_local_server_occupied_port"
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    # This test fails if the hostname is not associated with an IP (e.g., in `/etc/hosts`).
    "test_run_local_server_bind_addr"
  ];

  optional-dependencies = {
    tool = [ click ];
  };

  pyproject = true;
  pythonImportsCheck = [ "google_auth_oauthlib" ];
  sourceRoot = "${finalAttrs.src.name}/packages/google-auth-oauthlib";

  # The ATOM feed loses this update most of the time due to a high update volume,
  # so query github directly.
  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version-regex"
      "google-auth-oauthlib-v([0-9.]+)"
      "--use-github-releases"
    ];
  };

  meta = {
    description = "Google Authentication Library: oauthlib integration";
    homepage = "https://github.com/googleapis/google-cloud-python/tree/main/packages/google-auth-oauthlib";
    changelog = "https://github.com/googleapis/google-cloud-python/blob/${finalAttrs.src.tag}/packages/google-auth-oauthlib/CHANGELOG.md";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      sarahec
      terlar
    ];

    mainProgram = "google-oauthlib-tool";
  };
})
