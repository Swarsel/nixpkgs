{
  lib,
  fetchFromGitHub,
  buildGo126Module,
  icu,
  nix-update-script,
  testers,
  unixodbc,
  usql,
}:

buildGo126Module (finalAttrs: {
  pname = "usql";
  version = "0.21.4";

  src = fetchFromGitHub {
    owner = "xo";
    repo = "usql";
    tag = "v${finalAttrs.version}";
    hash = "sha256-8T3/IuTf7ui/yj9yy/HIOD5/8IQx1Zoodd7nmmGhla8=";
  };

  buildInputs = [
    unixodbc
    icu
  ];

  vendorHash = "sha256-GxU3NLLUJgMTrdtnlyDGivKdf8xjRekpz5gHm7CrWqY=";
  # All the checks currently require docker instances to run the databases.
  doCheck = false;

  # Exclude drivers from the bad group
  # These drivers break too often and are not used.
  #
  excludedPackages = [
    "impala"
  ];

  ldflags = [
    "-s"
    "-w"
    "-X github.com/xo/usql/text.CommandVersion=${finalAttrs.version}"
  ];

  proxyVendor = true;

  # These tags and flags are copied from build.sh
  tags = [
    "most"
    "sqlite_app_armor"
    "sqlite_fts5"
    "sqlite_introspect"
    "sqlite_json1"
    "sqlite_math_functions"
    "sqlite_stat4"
    "sqlite_vtable"
    "no_adodb"
  ];

  passthru = {
    tests.version = testers.testVersion {
      inherit (finalAttrs) version;
      command = "usql --version";
      package = usql;
    };

    updateScript = nix-update-script { };
  };

  meta = {
    description = "Universal command-line interface for SQL databases";
    homepage = "https://github.com/xo/usql";
    changelog = "https://github.com/xo/usql/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      georgyo
      anthonyroussel
    ];

    platforms = with lib.platforms; linux ++ darwin;
    mainProgram = "usql";
  };
})
