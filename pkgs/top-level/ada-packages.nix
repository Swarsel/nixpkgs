{
  lib,
  generateSplicesForMkScope,
  gnat,
  makeScopeWithSplicing',
  pkgs,
}:
let
  gnat_version = lib.versions.major gnat.version;
in
makeScopeWithSplicing' {
  f = (
    self: {
      inherit gnat;
      gnatcoll-core = self.callPackage ../development/ada-modules/gnatcoll/core.nix { };

      # gnatcoll-bindings repository
      gnatcoll-cpp = self.callPackage ../development/ada-modules/gnatcoll/bindings.nix {
        component = "cpp";
      };

      gnatcoll-db2ada = self.callPackage ../development/ada-modules/gnatcoll/db.nix {
        component = "gnatcoll_db2ada";
      };

      gnatcoll-gmp = self.callPackage ../development/ada-modules/gnatcoll/bindings.nix {
        component = "gmp";
      };

      gnatcoll-iconv = self.callPackage ../development/ada-modules/gnatcoll/bindings.nix {
        component = "iconv";
      };

      gnatcoll-lzma = self.callPackage ../development/ada-modules/gnatcoll/bindings.nix {
        component = "lzma";
      };

      gnatcoll-omp = self.callPackage ../development/ada-modules/gnatcoll/bindings.nix {
        component = "omp";
      };

      # gnatcoll-db repository
      gnatcoll-postgres = self.callPackage ../development/ada-modules/gnatcoll/db.nix {
        component = "postgres";
      };

      gnatcoll-python3 = self.callPackage ../development/ada-modules/gnatcoll/bindings.nix {
        component = "python3";
        python3 = pkgs.python312;
      };

      gnatcoll-readline = self.callPackage ../development/ada-modules/gnatcoll/bindings.nix {
        component = "readline";
      };

      gnatcoll-sql = self.callPackage ../development/ada-modules/gnatcoll/db.nix { component = "sql"; };

      gnatcoll-sqlite = self.callPackage ../development/ada-modules/gnatcoll/db.nix {
        component = "sqlite";
      };

      gnatcoll-syslog = self.callPackage ../development/ada-modules/gnatcoll/bindings.nix {
        component = "syslog";
      };

      gnatcoll-xref = self.callPackage ../development/ada-modules/gnatcoll/db.nix { component = "xref"; };

      gnatcoll-zlib = self.callPackage ../development/ada-modules/gnatcoll/bindings.nix {
        component = "zlib";
      };

      gnatinspect = self.callPackage ../development/ada-modules/gnatcoll/db.nix {
        component = "gnatinspect";
      };

      gnatprove =
        # They haven't released a version of gnatprove for gnat16 yet
        if lib.versionOlder gnat.version "16" then
          self.callPackage ../development/ada-modules/gnatprove {
            ocamlPackages = pkgs.ocaml-ng.ocamlPackages_4_14;
          }
        else
          null;

      gpr2 = self.callPackage ../development/ada-modules/gpr2 { };
      gprbuild = self.callPackage ../development/ada-modules/gprbuild { };
      gprbuild-boot = self.callPackage ../development/ada-modules/gprbuild/boot.nix { };
      xmlada = self.callPackage ../development/ada-modules/xmlada { };
    }
  );

  otherSplices = generateSplicesForMkScope ("gnat" + gnat_version + "Packages");
}
