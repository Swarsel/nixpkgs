{
  lib,
  fetchFromGitHub,
  buildGoModule,
  nix-update-script,
}:
buildGoModule (finalAttrs: {
  pname = "double-entry-generator";
  version = "2.15.1";

  src = fetchFromGitHub {
    owner = "deb-sig";
    repo = "double-entry-generator";
    rev = "v${finalAttrs.version}";
    hash = "sha256-lOV62FOqenL/vggYrR2vgKtSu5JSmDf3ofRS39co2fk=";
  };

  vendorHash = "sha256-aOzqxXGBjrIZcE0GfnPC3B3GrbSUgkvimkzLTcthspM=";
  doInstallCheck = true;

  installCheckPhase = ''
    runHook preInstallCheck

    touch build-local
    ln -s $out/bin ./
    make SHELL=bash GIT_COMMIT= VERSION= DOCKER_LABELS= -o test-go test

    runHook postInstallCheck
  '';

  excludedPackages = [ "hack" ];

  ldflags = [
    "-s"
    "-w"
    "-X=github.com/deb-sig/double-entry-generator/pkg/version.VERSION=${finalAttrs.version}"
    "-X=github.com/deb-sig/double-entry-generator/pkg/version.REPOROOT=github.com/deb-sig/double-entry-generator"
    "-X=github.com/deb-sig/double-entry-generator/pkg/version.COMMIT=${finalAttrs.src.rev}"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Rule-based double-entry bookkeeping importer (from Alipay/WeChat/Huobi etc. to Beancount/Ledger)";
    homepage = "https://github.com/deb-sig/double-entry-generator";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ rennsax ];
    mainProgram = "double-entry-generator";
  };
})
