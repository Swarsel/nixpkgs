{
  buildEnv,
  postgresql,
  postgresqlTestExtension,
  python3,
}:

let
  withPackages =
    f:
    let
      python = python3.withPackages f;
      finalPackage = buildEnv {
        inherit (postgresql) version;
        pname = "${postgresql.pname}-plpython3";
        paths = [ postgresql.plpython3 ];

        passthru = {
          inherit withPackages;

          tests.extension = postgresqlTestExtension {
            finalPackage = finalPackage.withPackages (ps: [ ps.base58 ]);

            sql = ''
              CREATE EXTENSION plpython3u;
              DO LANGUAGE plpython3u $$
                import base58
              $$;
            '';
          };

          wrapperArgs = [
            ''--set PYTHONPATH "${python}/${python.sitePackages}"''
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

          description = "PL/Python - Python Procedural Language";
        };
      };
    in
    finalPackage;
in
withPackages (_: [ ])
