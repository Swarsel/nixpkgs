{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "goose";
  version = "3.27.2";

  src = fetchFromGitHub {
    owner = "pressly";
    repo = "goose";
    rev = "v${finalAttrs.version}";
    hash = "sha256-4m/YYyQtz/Nj94vIUxChgmDsJVZqtzmp7qsSiuZVB38=";
  };

  # skipping: end-to-end tests require a docker daemon
  postPatch = ''
    rm -r tests/gomigrations
  '';

  vendorHash = "sha256-8riGHomL3wKqBOPOzgE13jWYjJT03tqz1UMWR/01pcE=";
  doCheck = !stdenv.hostPlatform.isDarwin;

  checkFlags = [
    # NOTE:
    # - skipping: these also require a docker daemon
    # - these are for go tests that live outside of the /tests directory
    "-skip=TestClickUpDown|TestClickHouseFirstThree|TestLockModeAdvisorySession|TestDialectStore|TestGoMigrationStats|TestPostgresSessionLocker"
  ];

  ldflags = [
    "-s"
    "-w"
    "-X=main.version=${finalAttrs.version}"
  ];

  proxyVendor = true;

  subPackages = [
    "cmd/goose"
  ];

  meta = {
    description = "Database migration tool which supports SQL migrations and Go functions";
    homepage = "https://pressly.github.io/goose/";
    license = lib.licenses.bsd3;
    maintainers = [ ];
    mainProgram = "goose";
  };
})
