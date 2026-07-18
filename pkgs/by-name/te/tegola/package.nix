{
  lib,
  fetchFromGitHub,
  buildGoModule,
  buildNpmPackage,
}:
let
  version = "0.21.2";

  src = fetchFromGitHub {
    owner = "go-spatial";
    repo = "tegola";
    tag = "v${version}";
    hash = "sha256-aJCxxeewOm7DOHmehnsDKoQPwPnUMsjVit41ccY6tLg=";
  };

  frontend = buildNpmPackage {
    inherit version;
    pname = "tegola-ui";
    src = "${src}/ui";
    npmDepsHash = "sha256-DHJ+l3ceLieGG97kH1ri+7yZAv7R2lVYRdBhjXCy/iM=";

    installPhase = ''
      cp -r dist $out
    '';
  };
in
buildGoModule {
  inherit version src;
  pname = "tegola";
  vendorHash = null;

  preBuild = ''
    rm -rf ui/dist
    cp -r ${frontend} ui/dist
    go generate ./server
  '';

  ldflags = [
    "-s"
    "-w"
    "-X github.com/go-spatial/tegola/internal/build.Version=${version}"
  ];

  subPackages = [ "cmd/tegola" ];

  meta = {
    description = "Mapbox Vector Tile server";
    homepage = "https://www.tegola.io/";
    license = lib.licenses.mit;
    mainProgram = "tegola";
    teams = [ lib.teams.geospatial ];
  };
}
