{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "asnmap";
  version = "1.1.1";

  src = fetchFromGitHub {
    owner = "projectdiscovery";
    repo = "asnmap";
    tag = "v${finalAttrs.version}";
    hash = "sha256-dGSWUuM4Zcz9QYjYaHur3RYryxe1wJycx/wUL5yqCpM=";
  };

  vendorHash = "sha256-bSpMYQvrlR9T06dYF8gaTZmMAp6Gnb2cfsYCUes7i2s=";
  # Tests require network access
  doCheck = false;

  ldflags = [
    "-w"
    "-s"
  ];

  meta = {
    description = "Tool to gather network ranges using ASN information";
    homepage = "https://github.com/projectdiscovery/asnmap";
    changelog = "https://github.com/projectdiscovery/asnmap/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "asnmap";
  };
})
