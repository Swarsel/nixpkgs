{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  buildPackages,
  fulcio,
  # required for completion and cross-compilation
  installShellFiles,
  # required for testing
  testers,
}:

buildGoModule (finalAttrs: {
  pname = "fulcio";
  version = "1.8.8";

  src = fetchFromGitHub {
    owner = "sigstore";
    repo = "fulcio";
    tag = "v${finalAttrs.version}";
    hash = "sha256-MKXJAk4N6Q/VM7/8Ri08rfrxHRw5FvOoreFrMp2SoE0=";
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
  vendorHash = "sha256-Bpu6PR3i+Sq5tZhCPLYi4rECwZ/QiN3Wls7U+8f6fBU=";

  # ldflags based on metadata from git and source
  preBuild = ''
    ldflags+=" -X sigs.k8s.io/release-utils/version.gitCommit=$(cat COMMIT)"
    ldflags+=" -X sigs.k8s.io/release-utils/version.buildDate=$(cat SOURCE_DATE_EPOCH)"
  '';

  checkFlags = [
    "-skip=TestLoad"
  ];

  preCheck = ''
    # test all paths
    unset subPackages
  '';

  postInstall =
    let
      fulcio =
        if stdenv.buildPlatform.canExecute stdenv.hostPlatform then
          placeholder "out"
        else
          buildPackages.fulcio;
    in
    ''
      installShellCompletion --cmd fulcio \
        --bash <(${fulcio}/bin/fulcio completion bash) \
        --fish <(${fulcio}/bin/fulcio completion fish) \
        --zsh <(${fulcio}/bin/fulcio completion zsh)
    '';

  ldflags = [
    "-s"
    "-w"
    "-X sigs.k8s.io/release-utils/version.gitVersion=v${finalAttrs.version}"
    "-X sigs.k8s.io/release-utils/version.gitTreeState=clean"
  ];

  subPackages = [ "." ];

  passthru.tests.version = testers.testVersion {
    version = "v${finalAttrs.version}";
    command = "fulcio version";
    package = fulcio;
  };

  meta = {
    description = "Root-CA for code signing certs - issuing certificates based on an OIDC email address";

    longDescription = ''
      Fulcio is a free code signing Certificate Authority, built to make
      short-lived certificates available to anyone. Based on an Open ID Connect
      email address, Fulcio signs x509 certificates valid for under 20 minutes.

      Fulcio was designed to run as a centralized, public-good instance backed
      up by other transparency logs. Development is now underway to support
      different delegation models, and to deploy and run Fulcio as a
      disconnected instance.
    '';

    homepage = "https://github.com/sigstore/fulcio";
    changelog = "https://github.com/sigstore/fulcio/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      lesuisse
      jk
    ];

    mainProgram = "fulcio";
  };
})
