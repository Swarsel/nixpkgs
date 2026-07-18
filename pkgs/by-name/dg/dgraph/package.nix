{
  lib,
  fetchFromGitHub,
  buildGoModule,
  installShellFiles,
  jemalloc,
  nodejs,
}:

buildGoModule (finalAttrs: {
  pname = "dgraph";
  version = "25.3.8";

  src = fetchFromGitHub {
    owner = "dgraph-io";
    repo = "dgraph";
    tag = "v${finalAttrs.version}";
    hash = "sha256-RrOlJVkekZ3xWGtjc013YyCycJmlPowVzqrttnZD8BI=";
  };

  nativeBuildInputs = [ installShellFiles ];

  # todo those dependencies are required in the makefile, but verify how they are used
  # actually
  buildInputs = [
    jemalloc
    nodejs
  ];

  vendorHash = "sha256-gD91KGWLqd6a7YkqQSeW1eS2MQI+1/RbI5X1/Xwrz90=";
  doCheck = false;

  postInstall = ''
    for shell in bash zsh; do
      $out/bin/dgraph completion $shell > dgraph.$shell
      installShellCompletion dgraph.$shell
    done
  '';

  ldflags = [
    "-X github.com/dgraph-io/dgraph/x.dgraphVersion=${finalAttrs.version}-oss"
  ];

  subPackages = [ "dgraph" ];

  tags = [
    "oss"
  ];

  meta = {
    description = "Fast, Distributed Graph DB";
    homepage = "https://dgraph.io/";
    # Apache 2.0 because we use only build "oss"
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      sarahec
      sigma
    ];

    mainProgram = "dgraph";
  };
})
