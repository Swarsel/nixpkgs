{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  container-structure-test,
  installShellFiles,
  testers,
}:
buildGoModule (finalAttrs: {
  pname = "container-structure-test";
  version = "1.22.1";

  src = fetchFromGitHub {
    owner = "GoogleContainerTools";
    repo = "container-structure-test";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-iNJH5mrDRlwS4qry0OyT/MRlGjHbKjWZbppkbTX6ksI=";
  };

  nativeBuildInputs = [ installShellFiles ];
  vendorHash = "sha256-pBq76HJ+nluOMOs9nqBKp1mr1LuX2NERXo48g8ezE9k=";

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    for shell in bash fish zsh; do
      $out/bin/container-structure-test completion $shell > executor.$shell
      installShellCompletion executor.$shell
    done
  '';

  ldflags = [
    "-X github.com/${finalAttrs.src.owner}/${finalAttrs.src.repo}/pkg/version.version=${finalAttrs.version}"
    "-X github.com/${finalAttrs.src.owner}/${finalAttrs.src.repo}/pkg/version.buildDate=1970-01-01T00:00:00Z"
  ];

  subPackages = [ "cmd/container-structure-test" ];

  passthru.tests.version = testers.testVersion {
    version = finalAttrs.version;
    command = "${lib.getExe container-structure-test} version";
    package = container-structure-test;
  };

  meta = {
    description = "Framework to validate the structure of a container image";
    homepage = "https://github.com/GoogleContainerTools/container-structure-test";
    license = lib.licenses.asl20;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ rubenhoenle ];
    platforms = lib.platforms.darwin ++ lib.platforms.linux;
    mainProgram = "container-structure-test";
  };
})
