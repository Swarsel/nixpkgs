{ cosmopolitan, runCommand }:

let
  cosmocc =
    runCommand "cosmocc-${cosmopolitan.version}"
      {
        inherit (cosmopolitan) version;
        pname = "cosmocc";

        passthru.tests = {
          cc = runCommand "c-test" { } ''
            ${cosmocc}/bin/cosmocc ${./hello.c}
            ./a.out > $out
          '';
        };

        meta = cosmopolitan.meta // {
          description = "Compilers for Cosmopolitan C/C++ programs";
        };
      }
      ''
        mkdir -p $out/bin
        install ${cosmopolitan.dist}/tool/scripts/{cosmocc,cosmoc++} $out/bin
        sed 's|/opt/cosmo\([ /]\)|${cosmopolitan.dist}\1|g' -i $out/bin/*
      '';
in
cosmocc
