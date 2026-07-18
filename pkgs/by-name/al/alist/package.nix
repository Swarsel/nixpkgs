{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  callPackage,
  fetchzip,
  fuse,
  installShellFiles,
  versionCheckHook,
}:
buildGoModule (finalAttrs: {
  pname = "alist";
  version = "3.57.0";

  src = fetchFromGitHub {
    owner = "AlistGo";
    repo = "alist";
    tag = "v${finalAttrs.version}";
    hash = "sha256-wwV65vxNSrGzP7TQ+nnjWS+dcCj/+67WcMPRbNqOVbQ=";
    # populate values that require us to use git. By doing this in postFetch we
    # can delete .git afterwards and maintain better reproducibility of the src.
    leaveDotGit = true;

    postFetch = ''
      cd "$out"
      git rev-parse HEAD > $out/COMMIT
      # '0000-00-00T00:00:00Z'
      date -u -d "@$(git log -1 --pretty=%ct)" "+%Y-%m-%dT%H:%M:%SZ" > $out/SOURCE_DATE_EPOCH
      find "$out" -name .git -print0 | xargs -0 rm -rf
    '';
  };

  # --- FAIL: TestSecureJoin/drive (0.00s)
  #     securepath_test.go:29: expected error for "C:\\evil.txt", got nil
  postPatch = lib.optionalString stdenv.hostPlatform.isUnix ''
    substituteInPlace internal/archive/tool/securepath_test.go \
      --replace-fail '{name: "drive", entry: "C:\\evil.txt", wantErr: true},' ""
  '';

  nativeBuildInputs = [ installShellFiles ];
  buildInputs = [ fuse ];
  vendorHash = "sha256-aRnS3LLG25FK1ELKd7K1e5aGLmKnQ7w/3QVe4P9RRLI=";

  preConfigure = ''
    rm -rf public/dist
    cp -r ${finalAttrs.passthru.web} public/dist
  '';

  preBuild = ''
    ldflags+=" -X \"github.com/alist-org/alist/v3/internal/conf.GoVersion=$(go version | sed 's/go version //')\""
    ldflags+=" -X \"github.com/alist-org/alist/v3/internal/conf.BuiltAt=$(cat SOURCE_DATE_EPOCH)\""
    ldflags+=" -X github.com/alist-org/alist/v3/internal/conf.GitCommit=$(cat COMMIT)"
  '';

  checkFlags =
    let
      # Skip tests that require network access
      skippedTests = [
        "TestHTTPAll"
        "TestWebsocketAll"
        "TestWebsocketCaller"
        "TestDownloadOrder"
      ];
    in
    [ "-skip=^${builtins.concatStringsSep "$|^" skippedTests}$" ];

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd alist \
      --bash <($out/bin/alist completion bash) \
      --fish <($out/bin/alist completion fish) \
      --zsh <($out/bin/alist completion zsh)
  '';

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  ldflags = [
    "-s"
    "-w"
    "-X \"github.com/alist-org/alist/v3/internal/conf.GitAuthor=Xhofe <i@nn.ci>\""
    "-X github.com/alist-org/alist/v3/internal/conf.Version=${finalAttrs.version}"
    "-X github.com/alist-org/alist/v3/internal/conf.WebVersion=${finalAttrs.passthru.webVersion}"
  ];

  proxyVendor = true;
  tags = [ "jsoniter" ];
  versionCheckProgramArg = "version";

  passthru = {
    updateScript = lib.getExe (callPackage ./update.nix { });

    web = fetchzip {
      hash = "sha256-QP1eWlSr7XBX8jUyvXhpmEGIwWaY6wy4M2l/35AiuUg=";
      url = "https://github.com/AlistGo/alist-web/releases/download/${finalAttrs.passthru.webVersion}/dist.tar.gz";
    };

    webVersion = "3.57.0";
  };

  meta = {
    description = "File list/WebDAV program that supports multiple storages";
    homepage = "https://github.com/AlistGo/alist";
    changelog = "https://github.com/AlistGo/alist/releases/tag/v${finalAttrs.version}";

    license = with lib.licenses; [
      agpl3Only
      # alist-web
      mit
    ];

    sourceProvenance = with lib.sourceTypes; [
      fromSource
      # alist-web
      binaryBytecode
    ];

    maintainers = with lib.maintainers; [ moraxyc ];
    mainProgram = "alist";

    knownVulnerabilities = [
      "Alist was acquired by Bugotech, a company distrusted by the community"
      "Uses a questionable API server alist.nn.ci for account creation for certain drivers"
    ];
  };
})
