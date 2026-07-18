{
  lib,
  stdenv,
  fetchurl,
  sqlite,
  tcl,
  unzip,
}:

let
  archiveVersion = import ./archive-version.nix lib;
  mkTool =
    {
      description,
      homepage,
      mainProgram,
      makeTarget,
      pname,
    }:
    stdenv.mkDerivation rec {
      inherit pname;
      version = "3.53.1";

      # nixpkgs-update: no auto update
      src =
        assert version == sqlite.version;
        fetchurl {
          url = "https://sqlite.org/2026/sqlite-src-${archiveVersion version}.zip";
          hash = "sha256-GytXVdkGTE1dGwv1MHtIsImWPikcQMxzUTGKobYcRg4=";
        };

      nativeBuildInputs = [ unzip ];
      buildInputs = [ tcl ];
      makeFlags = [ makeTarget ];
      installPhase = "install -Dt $out/bin ${makeTarget}";

      meta = {
        inherit description homepage mainProgram;
        license = lib.licenses.publicDomain;
        maintainers = with lib.maintainers; [ johnazoidberg ];
        platforms = lib.platforms.unix;
        downloadPage = "http://sqlite.org/download.html";
      };
    };
in
{
  sqldiff = mkTool {
    pname = "sqldiff";
    description = "Tool that displays the differences between SQLite databases";
    homepage = "https://www.sqlite.org/sqldiff.html";
    mainProgram = "sqldiff";
    makeTarget = "sqldiff";
  };

  sqlite-analyzer = mkTool {
    pname = "sqlite-analyzer";
    description = "Tool that shows statistics about SQLite databases";
    homepage = "https://www.sqlite.org/sqlanalyze.html";
    mainProgram = "sqlite3_analyzer";
    makeTarget = "sqlite3_analyzer";
  };

  sqlite-rsync = mkTool {
    pname = "sqlite-rsync";
    description = "Database remote-copy tool for SQLite";
    homepage = "https://www.sqlite.org/rsync.html";
    mainProgram = "sqlite3_rsync";
    makeTarget = "sqlite3_rsync";
  };
}
