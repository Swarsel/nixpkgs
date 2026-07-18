{
  lib,
  fetchFromGitHub,
  buildGoModule,
  buildNpmPackage,
}:

let
  version = "0.4.10-unstable-2024-10-25";
  src = fetchFromGitHub {
    owner = "zinclabs";
    repo = "zincsearch";
    rev = "0652db6d39badc753f28ee1122dcbc0e5da1c35e";
    hash = "sha256-Py4fiZJ2fMwPe2afd19brR+62PGVoU67nMDMPlUFhKQ=";
  };

  webui = buildNpmPackage {
    inherit src version;
    pname = "zinc-ui";
    npmDepsHash = "sha256-2AjUaEOn2Tj+X4f42SvNq1kX07WxkB1sl5KtGdCjbdw=";

    env = {
      CYPRESS_INSTALL_BINARY = 0; # cypress tries to download binaries otherwise
    };

    installPhase = ''
      mkdir -p $out/share
      mv dist $out/share/zinc-ui
    '';

    sourceRoot = "${src.name}/web";
  };
in

buildGoModule rec {
  inherit src version;
  pname = "zincsearch";
  vendorHash = "sha256-JB6+sfMB7PgpPg1lmN9/0JFRLi1c7VBUMD/d4XmLIPw=";

  preBuild = ''
    cp -r ${webui}/share/zinc-ui web/dist
  '';

  ldflags = [
    "-s"
    "-w"
    "-X github.com/zinclabs/zincsearch/pkg/meta.Version=${version}"
  ];

  subPackages = [ "cmd/zincsearch" ];

  meta = {
    description = "Lightweight alternative to elasticsearch that requires minimal resources, written in Go";
    homepage = "https://zincsearch-docs.zinc.dev/";
    license = lib.licenses.asl20;
    maintainers = [ ];
    mainProgram = "zincsearch";
  };
}
