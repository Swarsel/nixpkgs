{
  lib,
  buildEnv,
  postgresql,
  postgresqlTestExtension,
  tclPackages,
}:

let
  withPackages =
    f:
    let
      pkgs = f tclPackages;
      paths = lib.concatMapStringsSep " " (pkg: "${pkg}/lib") pkgs;
      finalPackage = buildEnv {
        inherit (postgresql) version;
        pname = "${postgresql.pname}-pltcl";
        paths = [ postgresql.pltcl ];

        passthru = {
          inherit withPackages;

          tests.extension = postgresqlTestExtension {
            finalPackage = finalPackage.withPackages (ps: [
              ps.mustache-tcl
              ps.tcllib
            ]);

            sql = ''
              CREATE EXTENSION pltclu;
              CREATE FUNCTION test() RETURNS VOID
              LANGUAGE pltclu AS $$
                package require mustache
              $$;
              SELECT test();
            '';
          };

          wrapperArgs = [
            ''--set TCLLIBPATH "${paths}"''
          ];
        };

        meta = {
          inherit (postgresql.meta)
            homepage
            license
            changelog
            teams
            platforms
            ;

          description = "PL/Tcl - Tcl Procedural Language";
        };
      };
    in
    finalPackage;
in
withPackages (_: [ ])
