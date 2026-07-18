{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  fetchpatch,
  installShellFiles,
  versionCheckHook,
}:

let
  version = "0.19.2";
in
buildGoModule {
  inherit version;
  pname = "sbom-utility";

  src = fetchFromGitHub {
    owner = "CycloneDX";
    repo = "sbom-utility";
    tag = "v${version}";
    hash = "sha256-xjANZxjPQmaBZPt+yF2UTJ1QL7QN0wSFxNMZ2oF6p7s=";
  };

  nativeBuildInputs = [
    installShellFiles
  ];

  vendorHash = "sha256-vyYSir5u6d5nv+2ScrHpasQGER4VFSoLb1FDUDIrtDM=";

  preCheck = ''
    cd test
  '';

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    for shell in bash fish zsh; do
      installShellCompletion --cmd sbom-utility \
        --$shell <($out/bin/sbom-utility -q completion $shell)
    done
  '';

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  ldflags = [
    "-X main.Version=${version}"
  ];

  meta = {
    description = "Utility that provides an API platform for validating, querying and managing BOM data";
    homepage = "https://github.com/CycloneDX/sbom-utility";
    changelog = "https://github.com/CycloneDX/sbom-utility/releases/tag/v${version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ thillux ];
    mainProgram = "sbom-utility";
  };
}
