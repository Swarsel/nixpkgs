{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  ps,
  versionCheckHook,
}:

buildGoModule (finalAttrs: {
  pname = "clickhouse-backup";
  version = "2.7.4";

  src = fetchFromGitHub {
    owner = "Altinity";
    repo = "clickhouse-backup";
    tag = "v${finalAttrs.version}";
    hash = "sha256-HlVngChgU+Do6e5gfP1fg1R/fSGfB8kjG2Ul+N7eJkE=";
  };

  vendorHash = "sha256-HN0H2YFj7k/T2ff1GCrjfE9PO6MtdR/SWKZL/FoqHZ8=";

  postConfigure = ''
    export CGO_ENABLED=0
  '';

  checkFlags = lib.optionals stdenv.hostPlatform.isDarwin [ "-skip=TestParseCallback" ];

  preCheck = ''
    export PATH=${ps}/bin:$PATH
  '';

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  ldflags = [
    "-X main.version=${finalAttrs.version}"
  ];

  meta = {
    description = "Tool for easy ClickHouse backup and restore using object storage for backup files";
    homepage = "https://github.com/Altinity/clickhouse-backup";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ devusb ];
    mainProgram = "clickhouse-backup";
  };
})
