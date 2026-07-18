{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  installShellFiles,
}:

buildGoModule (finalAttrs: {
  pname = "zed";
  version = "1.1.1";

  src = fetchFromGitHub {
    owner = "authzed";
    repo = "zed";
    tag = "v${finalAttrs.version}";
    hash = "sha256-rlTcC2+faNZKvzouGC9nJBBCsDabxozTE/SFbf8YKQ8=";
  };

  nativeBuildInputs = [ installShellFiles ];
  vendorHash = "sha256-/nnPVy+pjcgkgJW8630IycmGF4Qq4I01htEDlsWvZbM=";
  # Version test expects '(devel)' but version is being set to the package version
  checkFlags = [ "--skip=TestGetClientVersion" ];

  preCheck = ''
    export NO_COLOR=true
  '';

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd zed \
      --bash <($out/bin/zed completion bash) \
      --fish <($out/bin/zed completion fish) \
      --zsh <($out/bin/zed completion zsh)
  '';

  ldflags = [ "-X 'github.com/jzelinskie/cobrautil/v2.Version=${finalAttrs.src.tag}'" ];

  meta = {
    description = "Command line for managing SpiceDB";

    longDescription = ''
      SpiceDB is an open-source permissions database inspired by
      Google Zanzibar. zed is the command line client for SpiceDB.
    '';

    homepage = "https://authzed.com/";
    changelog = "https://github.com/authzed/zed/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      squat
      thoughtpolice
    ];

    mainProgram = "zed";
  };
})
