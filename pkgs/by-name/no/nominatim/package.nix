{
  lib,
  fetchurl,
  fetchFromGitHub,
  nixosTests,
  nominatim, # required for testVersion
  osm2pgsql,
  python3Packages,
  testers,
}:

let
  countryGrid = fetchurl {
    hash = "sha256-/mY5Oq9WF0klXOv0xh0TqEJeMmuM5QQJ2IxANRZd4Ek=";
    # Nominatim-db needs https://www.nominatim.org/data/country_grid.sql.gz
    # but it's not a very good URL for pinning
    url = "https://web.archive.org/web/20220323041006/https://nominatim.org/data/country_grid.sql.gz";
  };
in
python3Packages.buildPythonApplication (finalAttrs: {
  pname = "nominatim";
  version = "5.3.2";

  src = fetchFromGitHub {
    owner = "osm-search";
    repo = "Nominatim";
    tag = "v${finalAttrs.version}";
    hash = "sha256-jP/OkEuFdVdvA8Uztv/49FXm9dsExVDjw2l2gyMOSsg=";
  };

  postPatch = ''
    # Fix: FileExistsError: File already exists: ... nominatim_db/paths.py
    # pyproject.toml tool.hatch.build.targets.sdist.exclude is not properly
    # excluding paths.py file.
    rm src/nominatim_db/paths.py

    # Install country_osm_grid.sql.gz required for data import
    cp ${countryGrid} ./data/country_osm_grid.sql.gz

    # Change to package directory
    cd packaging/nominatim-db
  '';

  propagatedBuildInputs = [
    osm2pgsql
  ];

  build-system = with python3Packages; [
    hatchling
  ];

  dependencies = with python3Packages; [
    nominatim-api

    jinja2
    psutil
    psycopg
    pyicu
    python-dotenv
    pyyaml
    mwparserfromhell
  ];

  pyproject = true;
  pythonImportsCheck = [ "nominatim_db" ];

  passthru.tests = {
    inherit (nixosTests) nominatim;
    version = testers.testVersion { package = nominatim; };
  };

  meta = {
    description = "Search engine for OpenStreetMap data (DB, CLI)";
    homepage = "https://nominatim.org/";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ mausch ];
    platforms = lib.platforms.unix;
    mainProgram = "nominatim";

    teams = with lib.teams; [
      geospatial
      ngi
    ];
  };
})
