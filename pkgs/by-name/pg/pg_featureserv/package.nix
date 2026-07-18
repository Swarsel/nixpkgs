{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "pg_featureserv";
  version = "1.3.1";

  src = fetchFromGitHub {
    owner = "CrunchyData";
    repo = "pg_featureserv";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-GsloUZFgrOrJc23vKv+8iSeyIEKblaukPSCpZGRtSL4=";
  };

  postPatch = ''
    # fix default configuration file location
    substituteInPlace \
      internal/conf/config.go \
      --replace-fail "viper.AddConfigPath(\"/etc\")" "viper.AddConfigPath(\"$out/share/config\")"

    # fix assets location in configuration file
    substituteInPlace \
      config/pg_featureserv.toml.example \
      --replace-fail "AssetsPath = \"./assets\"" "AssetsPath = \"$out/share/assets\""
  '';

  vendorHash = "sha256-BHiEVyi3FXPovYy3iDP8q+y+LgfI4ElDPVZexd7nnuo=";

  postInstall = ''
    mkdir -p $out/share
    cp -r assets $out/share

    mkdir -p $out/share/config
    cp config/pg_featureserv.toml.example $out/share/config/pg_featureserv.toml
  '';

  ldflags = [
    "-s"
    "-w"
    "-X github.com/CrunchyData/pg_featureserv/conf.setVersion=${finalAttrs.version}"
  ];

  meta = {
    description = "Lightweight RESTful Geospatial Feature Server for PostGIS in Go";
    homepage = "https://github.com/CrunchyData/pg_featureserv";
    license = lib.licenses.asl20;
    mainProgram = "pg_featureserv";
    teams = [ lib.teams.geospatial ];
  };
})
