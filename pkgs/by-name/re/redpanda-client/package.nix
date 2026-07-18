{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  installShellFiles,
  doCheck ? !stdenv.hostPlatform.isDarwin, # Can't start localhost test server in MacOS sandbox.
}:
let
  version = "26.1.12";
  src = fetchFromGitHub {
    owner = "redpanda-data";
    repo = "redpanda";
    rev = "v${version}";
    sha256 = "sha256-ZF9YzRW1b40syRCV+a5NOsS/SDwstVs1mI++dTDcpWc=";
  };
in
buildGoModule rec {
  inherit doCheck src version;
  pname = "redpanda-rpk";
  nativeBuildInputs = [ installShellFiles ];
  vendorHash = "sha256-g+LZgjD6wAuIDHweXYyZMxVT0Y8YWphC7ZzhBS9ozKk=";

  postInstall = ''
    for shell in bash fish zsh; do
      $out/bin/rpk generate shell-completion $shell > rpk.$shell
      installShellCompletion rpk.$shell
    done
  '';

  ldflags = [
    ''-X "github.com/redpanda-data/redpanda/src/go/rpk/pkg/cli/cmd/version.version=${version}"''
    ''-X "github.com/redpanda-data/redpanda/src/go/rpk/pkg/cli/cmd/version.rev=v${version}"''
    ''-X "github.com/redpanda-data/redpanda/src/go/rpk/pkg/cli/cmd/container/common.tag=v${version}"''
  ];

  modRoot = "./src/go/rpk";
  runVend = false;

  meta = {
    description = "Redpanda client";
    homepage = "https://redpanda.com/";
    license = lib.licenses.bsl11;

    maintainers = with lib.maintainers; [
      avakhrenev
      happysalada
    ];

    platforms = lib.platforms.all;
    mainProgram = "rpk";
  };
}
