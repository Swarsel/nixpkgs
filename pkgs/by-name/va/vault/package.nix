{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  gawk,
  glibc,
  installShellFiles,
  makeWrapper,
  nixosTests,
}:

buildGoModule (finalAttrs: {
  pname = "vault";
  version = "2.0.3";

  src = fetchFromGitHub {
    owner = "hashicorp";
    repo = "vault";
    rev = "v${finalAttrs.version}";
    hash = "sha256-s6Muogxe+jvre1qZYRiSGTDgMf0+BVsSOwyxF6+Aa2o=";
  };

  nativeBuildInputs = [
    installShellFiles
    makeWrapper
  ];

  vendorHash = "sha256-utF/CgWNtJNin5NIq7ZGjNc7YbjAuN5nm/G57uQal94=";

  postInstall = ''
    echo "complete -C $out/bin/vault vault" > vault.bash
    installShellCompletion vault.bash
  ''
  + lib.optionalString stdenv.hostPlatform.isLinux ''
    wrapProgram $out/bin/vault \
      --prefix PATH ${
        lib.makeBinPath [
          gawk
          glibc
        ]
      }
  '';

  ldflags = [
    "-s"
    "-w"
    "-X github.com/hashicorp/vault/sdk/version.GitCommit=${finalAttrs.src.rev}"
    "-X github.com/hashicorp/vault/sdk/version.Version=${finalAttrs.version}"
    "-X github.com/hashicorp/vault/sdk/version.VersionPrerelease="
  ];

  proxyVendor = true;
  subPackages = [ "." ];
  tags = [ "vault" ];

  passthru.tests = {
    inherit (nixosTests)
      vault
      vault-postgresql
      vault-dev
      vault-agent
      ;
  };

  meta = {
    description = "Tool for managing secrets";
    homepage = "https://developer.hashicorp.com/vault";
    changelog = "https://github.com/hashicorp/vault/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.bsl11;

    maintainers = with lib.maintainers; [
      rushmorem
      Chili-Man
      techknowlogick
    ];

    mainProgram = "vault";
  };
})
