{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "hasura";
  version = "2.48.11";

  src = fetchFromGitHub {
    owner = "hasura";
    repo = "graphql-engine";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-ySZ2dbu3W7JfsE20r9AUG4/JbI5DN9MS7lPe8NXjpQ0=";
  };

  vendorHash = "sha256-riPCH7H1arKP2se2H52R69fL+DyKXK1i/ne5apoS/5w=";
  doCheck = false;

  postInstall = ''
    mkdir -p $out/share/{bash-completion/completions,zsh/site-functions}

    export HOME=$PWD
    $out/bin/hasura completion bash > $out/share/bash-completion/completions/hasura
    $out/bin/hasura completion zsh > $out/share/zsh/site-functions/_hasura
  '';

  ldflags = [
    "-X github.com/hasura/graphql-engine/cli/version.BuildVersion=${finalAttrs.version}"
    "-s"
    "-w"
  ];

  modRoot = "./cli";
  subPackages = [ "cmd/hasura" ];

  meta = {
    description = "Hasura GraphQL Engine CLI";
    homepage = "https://www.hasura.io";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.lassulus ];
    mainProgram = "hasura";
  };
})
