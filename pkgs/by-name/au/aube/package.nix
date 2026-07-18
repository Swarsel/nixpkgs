{
  lib,
  fetchFromGitHub,
  cacert,
  cmake,
  gitMinimal,
  nix-update-script,
  rustPlatform,
  versionCheckHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "aube";
  version = "1.27.0";

  src = fetchFromGitHub {
    owner = "jdx";
    repo = "aube";
    tag = "v${finalAttrs.version}";
    hash = "sha256-lnW5ZLcdkpt662wDSj5YsnL7wILkJw3xoBs+3n7XWGY=";
  };

  strictDeps = true;
  nativeBuildInputs = [ cmake ]; # libz-ng-sys
  cargoHash = "sha256-Ox3l2VqtHfrAICTj7CL99EL5dXF43snPu7/X1ZFYceM=";
  env.SSL_CERT_FILE = "${cacert}/etc/ssl/certs/ca-bundle.crt";
  nativeCheckInputs = [ gitMinimal ];

  checkFlags = [
    # failed on x86_64-linux
    "--skip=http::ticket_cache::tests::max_per_host_evicts_oldest"
    "--skip=http::ticket_cache::tests::invalidate_removes_all_for_host"
    # require network access
    "--skip=http::ticket_cache::tests::roundtrip_persists_across_open"
  ];

  postInstall = ''
    rm -f $out/bin/generate-{error-codes,settings}-docs
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  __darwinAllowLocalNetworking = true;
  __structuredAttrs = true;
  passthru.updateScript = nix-update-script { extraArgs = [ "--use-github-releases" ]; };

  meta = {
    description = "Fast Node.js package manager";
    homepage = "https://github.com/jdx/aube";
    changelog = "https://github.com/jdx/aube/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      chillcicada
      Br1ght0ne
    ];

    mainProgram = "aube";
  };
})
