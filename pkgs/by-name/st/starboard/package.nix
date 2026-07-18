{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  installShellFiles,
  versionCheckHook,
}:

buildGoModule (finalAttrs: {
  pname = "starboard";
  version = "0.15.38";

  src = fetchFromGitHub {
    owner = "aquasecurity";
    repo = "starboard";
    tag = "v${finalAttrs.version}";
    hash = "sha256-DcNvkXPVcsS0czQhuLub7xlpZ3jfjW8Er3YclXerjMI=";
    # populate values that require us to use git. By doing this in postFetch we
    # can delete .git afterwards and maintain better reproducibility of the src.
    leaveDotGit = true;

    postFetch = ''
      cd "$out"
      git rev-parse HEAD > $out/COMMIT
      # 0000-00-00T00:00:00Z
      date -u -d "@$(git log -1 --pretty=%ct)" "+%Y-%m-%dT%H:%M:%SZ" > $out/SOURCE_DATE_EPOCH
      find "$out" -name .git -print0 | xargs -0 rm -rf
    '';
  };

  nativeBuildInputs = [ installShellFiles ];
  vendorHash = "sha256-UpPhTP+JObPJJMpMKPDriRgA5DETkMUlsobPACOfeho=";

  # ldflags based on metadata from git and source
  preBuild = ''
    ldflags+=" -X main.commit=$(cat COMMIT)"
    ldflags+=" -X main.date=$(cat SOURCE_DATE_EPOCH)"
  '';

  preCheck = ''
    # Remove test that requires networking
    rm pkg/plugin/aqua/client/client_integration_test.go
    ${lib.optionalString (stdenv.hostPlatform.isDarwin && stdenv.hostPlatform.isx86_64) ''
      # Remove "[It] should make a request to fetch registries" test that fails on x86_64-darwin
      rm pkg/plugin/aqua/client/client_test.go
    ''}

    # Feed in all but the integration tests for testing
    # This is because subPackages above limits what is built to just what we
    # want but also limits the tests
    getGoDirs() {
      go list ./... | grep -v itest
    }
  '';

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd starboard \
      --bash <($out/bin/starboard completion bash) \
      --fish <($out/bin/starboard completion fish) \
      --zsh <($out/bin/starboard completion zsh)
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  __darwinAllowLocalNetworking = true; # for tests

  ldflags = [
    "-s"
    "-w"
    "-X main.version=v${finalAttrs.version}"
  ];

  subPackages = [ "cmd/starboard" ];
  versionCheckProgramArg = "version";

  meta = {
    description = "Kubernetes-native security tool kit";

    longDescription = ''
      Starboard integrates security tools into the Kubernetes environment, so
      that users can find and view the risks that relate to different resources
      in a Kubernetes-native way. Starboard provides custom security resources
      definitions and a Go module to work with a range of existing security
      tools, as well as a kubectl-compatible command-line tool and an Octant
      plug-in that make security reports available through familiar Kubernetes
      tools.
    '';

    homepage = "https://github.com/aquasecurity/starboard";
    changelog = "https://github.com/aquasecurity/starboard/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ jk ];
    mainProgram = "starboard";
  };
})
