{
  lib,
  fetchFromGitHub,
  buildGoModule,
  callPackage,
  coreutils,
  curl,
  eksctl,
  jq,
  k3sup,
  kind,
  kubectl,
  makeWrapper,
  symlinkJoin,
}:

let
  branch = "3.0.0";
  version = "3.0.1-beta.2405292059";
  pname = "nuv";
in
buildGoModule {
  inherit pname version;

  src = fetchFromGitHub {
    owner = "nuvolaris";
    repo = "nuv";
    rev = version;
    hash = "sha256-MdnBvlA4S2Mi/bcbE+O02x+wvlIrsK1Zc0dySz4FB/w=";
  };

  nativeBuildInputs = [
    makeWrapper
    jq
    curl
  ];

  vendorHash = "sha256-JkQbQ2NEaumXbAfsv0fNiQf/EwMs3SDLHvu7c/bU7fU=";
  # false because tests require some modifications inside nix-env
  doCheck = false;

  postInstall =
    let
      nuv-bin = symlinkJoin {
        name = "nuv-bin";

        paths = [
          coreutils
          kubectl
          eksctl
          kind
          k3sup
        ];
      };
    in
    ''
      wrapProgram $out/bin/nuv --set NUV_BIN "${nuv-bin}/bin"
    '';

  ldflags = [
    "-s"
    "-w"
    "-X main.NuvVersion=${version}"
    "-X main.NuvBranch=${branch}"
  ];

  subPackages = [ "." ];

  passthru.tests = {
    simple = callPackage ./tests.nix { inherit version; };
  };

  meta = {
    description = "CLI tool for running tasks using the Nuvolaris serverless engine";
    homepage = "https://nuvolaris.io/";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      msciabarra
      d4rkstar
    ];

    mainProgram = "nuv";
  };
}
