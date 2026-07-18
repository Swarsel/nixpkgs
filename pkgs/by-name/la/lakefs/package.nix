{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  buildNpmPackage,
  installShellFiles,
  nix-update-script,
  nodejs_22,
  versionCheckHook,
}:

buildGoModule (finalAttrs: {
  pname = "lakefs";
  version = "1.83.0";

  src = fetchFromGitHub {
    owner = "treeverse";
    repo = "lakeFS";
    tag = "v${finalAttrs.version}";
    hash = "sha256-5/2iI5/87x+VJ1MbYw7zPEDeTm1XVuLmSsI6KssRGRE=";
  };

  nativeBuildInputs = [ installShellFiles ];
  vendorHash = "sha256-UNDIqP79CG2+M8HKkHT1l7X2/Dt6YDTQzADR5T7klUg=";

  preBuild = ''
    mkdir -p webui/dist
    cp -r ${finalAttrs.webui}/* webui/dist/
    go generate ./pkg/api/apigen ./pkg/auth ./pkg/authentication
  '';

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd lakefs \
      --bash <($out/bin/lakefs completion bash) \
      --fish <($out/bin/lakefs completion fish) \
      --zsh <($out/bin/lakefs completion zsh)
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  ldflags = [
    "-s"
    "-w"
    "-X github.com/treeverse/lakefs/pkg/version.Version=${finalAttrs.version}"
  ];

  proxyVendor = true;
  subPackages = [ "cmd/lakefs" ];

  webui = buildNpmPackage {
    inherit (finalAttrs) version src;
    pname = "lakefs-webui";
    npmDepsHash = "sha256-AKCsxBW2ZBQB5fPkS1adAt8z6mHuC/zGMHhRW8pVyYs=";

    installPhase = ''
      runHook preInstall
      cp -r dist $out
      runHook postInstall
    '';

    nodejs = nodejs_22;
    sourceRoot = "${finalAttrs.src.name}/webui";
  };

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Data version control for object storage (Git for data)";
    homepage = "https://lakefs.io/";
    changelog = "https://github.com/treeverse/lakeFS/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ philocalyst ];
    platforms = lib.platforms.unix;
    mainProgram = "lakefs";
    downloadPage = "https://github.com/treeverse/lakeFS";
  };
})
