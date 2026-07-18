{
  lib,
  fetchFromGitHub,
  buildNpmPackage,
  nix-update-script,
  openssl,
  pkg-config,
  rustPlatform,
}:
let
  pname = "sql-studio";
  version = "0.1.51";

  src = fetchFromGitHub {
    owner = "frectonz";
    repo = "sql-studio";
    tag = version;
    hash = "sha256-LooRM7KlNmRHG5M18MLnV+hraQ1kRVEZp2GVYnwNScI=";
  };

  ui = buildNpmPackage {
    inherit version src;
    pname = "sql-studio-ui";
    npmDepsHash = "sha256-4mDe8b5J1wrHz7OCClkE5WTbtfs3TMZB/vhiVuaHiyQ=";

    installPhase = ''
      runHook preInstall

      cp -pr --reflink=auto -- dist "$out/"

      runHook postInstall
    '';

    sourceRoot = "${src.name}/ui";
  };
in
rustPlatform.buildRustPackage {
  inherit pname version src;
  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ openssl ];
  cargoHash = "sha256-SJiPVvRYRkMHprGXtObNVSsO//2VNTpouCB+qcXlbjc=";

  preBuild = ''
    cp -pr --reflink=auto -- ${ui} ui/dist
  '';

  passthru = {
    inherit ui;

    updateScript = nix-update-script {
      extraArgs = [
        "--subpackage"
        "ui"
      ];
    };
  };

  meta = {
    description = "SQL Database Explorer [SQLite, libSQL, PostgreSQL, MySQL/MariaDB, ClickHouse, Microsoft SQL Server]";
    homepage = "https://github.com/frectonz/sql-studio";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.frectonz ];
    platforms = lib.platforms.all;
    mainProgram = "sql-studio";
  };
}
