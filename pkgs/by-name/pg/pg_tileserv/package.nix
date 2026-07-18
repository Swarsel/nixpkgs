{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "pg_tileserv";
  version = "1.0.11";

  src = fetchFromGitHub {
    owner = "CrunchyData";
    repo = "pg_tileserv";
    rev = "v${finalAttrs.version}";
    hash = "sha256-xTIx39eLmHBUlaUjQy9KGpi5X4AU93DzX+Ofg5PMLWE=";
  };

  postPatch = ''
    # fix default configuration file location
    substituteInPlace \
      main.go \
      --replace-fail "viper.AddConfigPath(\"/etc\")" "viper.AddConfigPath(\"$out/share/config\")"

    # fix assets location in configuration file
    substituteInPlace \
      config/pg_tileserv.toml.example \
      --replace-fail "# AssetsPath = \"/usr/share/pg_tileserv/assets\"" "AssetsPath = \"$out/share/assets\""
  '';

  vendorHash = "sha256-8CvYvoIKOYvR7npCV65ZqZGR8KCTH4GabTt/JGQG3uc=";
  doCheck = false;

  postInstall = ''
    mkdir -p $out/share
    cp -r assets $out/share

    mkdir -p $out/share/config
    cp config/pg_tileserv.toml.example $out/share/config/pg_tileserv.toml
  '';

  ldflags = [
    "-s"
    "-w"
    "-X main.programVersion=${finalAttrs.version}"
  ];

  meta = {
    description = "Very thin PostGIS-only tile server in Go";
    homepage = "https://github.com/CrunchyData/pg_tileserv";
    license = lib.licenses.asl20;
    mainProgram = "pg_tileserv";
    teams = [ lib.teams.geospatial ];
  };
})
