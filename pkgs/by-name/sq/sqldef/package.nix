{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "sqldef";
  version = "3.11.1";

  src = fetchFromGitHub {
    owner = "sqldef";
    repo = "sqldef";
    rev = "v${finalAttrs.version}";
    hash = "sha256-JUZwBy9aP649HSMLFIB7xrXlqc78JM3B+Ejci1pu+4E=";
  };

  vendorHash = "sha256-xX4ZrhIdHvNFRTXHkZfEbevauuv4x9IYfDVfq7IFDg8=";
  # The test requires a running database
  doCheck = false;

  ldflags = [
    "-s"
    "-w"
    "-X main.version=${finalAttrs.version}"
  ];

  proxyVendor = true;

  meta = {
    description = "Idempotent SQL schema management tool";
    homepage = "https://github.com/sqldef/sqldef";
    changelog = "https://github.com/sqldef/sqldef/blob/v${finalAttrs.version}/CHANGELOG.md";

    license = with lib.licenses; [
      mit # for everything except parser
      asl20 # for parser
    ];

    maintainers = with lib.maintainers; [ kgtkr ];
  };
})
