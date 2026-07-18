{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  installShellFiles,
  versionCheckHook,
}:

buildGoModule (finalAttrs: {
  pname = "vexctl";
  version = "0.4.1";

  src = fetchFromGitHub {
    owner = "openvex";
    repo = "vexctl";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ZPQsWTnVZ0B06QNQohUIvQN3/Wfk+LnYi/TOwDIKXug=";
    # populate values that require us to use git. By doing this in postFetch we
    # can delete .git afterwards and maintain better reproducibility of the src.
    leaveDotGit = true;

    postFetch = ''
      cd "$out"
      git rev-parse HEAD > $out/COMMIT
      # '0000-00-00T00:00:00Z'
      date -u -d "@$(git log -1 --pretty=%ct)" "+'%Y-%m-%dT%H:%M:%SZ'" > $out/SOURCE_DATE_EPOCH
      find "$out" -name .git -print0 | xargs -0 rm -rf
    '';
  };

  nativeBuildInputs = [ installShellFiles ];
  vendorHash = "sha256-G0w5auYmSED6ktTDayfOSu/9QQLTuFCkjW/f9ekn/Hw=";

  # ldflags based on metadata from git and source
  preBuild = ''
    ldflags+=" -X sigs.k8s.io/release-utils/version.gitCommit=$(cat COMMIT)"
    ldflags+=" -X sigs.k8s.io/release-utils/version.buildDate=$(cat SOURCE_DATE_EPOCH)"
  '';

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd vexctl \
      --bash <($out/bin/vexctl completion bash) \
      --fish <($out/bin/vexctl completion fish) \
      --zsh <($out/bin/vexctl completion zsh)
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  ldflags = [
    "-s"
    "-w"
    "-X sigs.k8s.io/release-utils/version.gitVersion=v${finalAttrs.version}"
    "-X sigs.k8s.io/release-utils/version.gitTreeState=clean"
  ];

  versionCheckProgramArg = "version";

  meta = {
    description = "Tool to create, transform and attest VEX metadata";
    homepage = "https://github.com/openvex/vexctl";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ jk ];
    mainProgram = "vexctl";
  };
})
