{
  lib,
  stdenv,
  __splicedPackages,
  callPackage,
  config,
  db,
  makeScopeWithSplicing',
  pythonPackagesExtensions,
}@args:

(
  let

    # Common passthru for all Python interpreters.
    passthruFun = import ./passthrufun.nix args;

    sources = {
      python314 = {
        hash = "sha256-FDsd3e+uw70uIeO4ObNKK3+5hCJyiDxXZCDWBenzDGM=";

        sourceVersion = {
          major = "3";
          minor = "14";
          patch = "6";
          suffix = "";
        };
      };
    };

  in
  {

    pypy27 = callPackage ./pypy {
      inherit passthruFun;
      db = db.override { dbmSupport = !stdenv.hostPlatform.isDarwin; };
      hash = "sha256-hwPNywH5+Clm3UO2pgGPFAOZ21HrtDwSXB+aIV57sAM=";
      python = __splicedPackages.pythonInterpreters.pypy27_prebuilt;
      pythonVersion = "2.7";
      self = __splicedPackages.pypy27;

      sourceVersion = {
        major = "7";
        minor = "3";
        patch = "19";
      };
    };

    pypy27_prebuilt = callPackage ./pypy/prebuilt_2_7.nix {
      inherit passthruFun;

      hash =
        {
          aarch64-darwin = "sha256-KHgOC5CK1ttLTglvQjcSS+eezJcxlG2EDZyHSetnp1k=";
          aarch64-linux = "sha256-/onU/UrxP3bf5zFZdQA1GM8XZSDjzOwVRKiNF09QkQ4=";
          x86_64-linux = "sha256-04RFUIwurxTrs4DZwd7TIcXr6uMcfmaAAXPYPLjd9CM=";
        }
        .${stdenv.system};

      pythonVersion = "2.7";
      # Not included at top-level
      self = __splicedPackages.pythonInterpreters.pypy27_prebuilt;

      sourceVersion = {
        major = "7";
        minor = "3";
        patch = "19";
      };
    };

    pypy310 = callPackage ./pypy {
      inherit passthruFun;
      db = db.override { dbmSupport = !stdenv.hostPlatform.isDarwin; };
      hash = "sha256-p8IpMLkY9Ahwhl7Yp0FH9ENO+E09bKKzweupNV1JKcg=";
      python = __splicedPackages.pypy27;
      pythonVersion = "3.10";
      self = __splicedPackages.pypy310;

      sourceVersion = {
        major = "7";
        minor = "3";
        patch = "19";
      };
    };

    pypy310_prebuilt = callPackage ./pypy/prebuilt.nix {
      inherit passthruFun;

      hash =
        {
          aarch64-darwin = "sha256-PbigP8SWFkgBZGhE1/OxK6oK2zrZoLfLEkUhvC4WijY=";
          aarch64-linux = "sha256-ryeliRePERmOIkSrZcpRBjC6l8Ex18zEAh61vFjef1c=";
          x86_64-linux = "sha256-xzrCzCOArJIn/Sl0gr8qPheoBhi6Rtt1RNU1UVMh7B4=";
        }
        .${stdenv.system};

      pythonVersion = "3.10";
      # Not included at top-level
      self = __splicedPackages.pythonInterpreters.pypy310_prebuilt;

      sourceVersion = {
        major = "7";
        minor = "3";
        patch = "19";
      };
    };

    pypy311 = callPackage ./pypy {
      inherit passthruFun;
      db = db.override { dbmSupport = !stdenv.hostPlatform.isDarwin; };
      hash = "sha256-d4bdp2AAPi6nQJwQN+UCAMV47EJ84CRaxM11hxCyBvs=";
      python = __splicedPackages.pypy27;
      pythonVersion = "3.11";
      self = __splicedPackages.pypy311;

      sourceVersion = {
        major = "7";
        minor = "3";
        patch = "20";
      };
    };

    pypy311_prebuilt = callPackage ./pypy/prebuilt.nix {
      inherit passthruFun;

      hash =
        {
          aarch64-darwin = "sha256-dwTg1TAuU5INMtz+mv7rEENtTJQjPogwz2A6qVWoYcE=";
          aarch64-linux = "sha256-EyB9v4HOJOltp2CxuGNie3e7ILH7TJUZHgKgtyOD33Q=";
          x86_64-linux = "sha256-kXfZ4LuRsF+SHGQssP9xoPNlO10ppC1A1qB4wVt1cg8=";
        }
        .${stdenv.system};

      pythonVersion = "3.11";
      # Not included at top-level
      self = __splicedPackages.pythonInterpreters.pypy311_prebuilt;

      sourceVersion = {
        major = "7";
        minor = "3";
        patch = "19";
      };
    };

    python311 = callPackage ./cpython {
      inherit passthruFun;
      hash = "sha256-JyF53dmi5BoPyOQuM9+9ygs3EapavzctPy1RVD0JtiU=";
      self = __splicedPackages.python311;

      sourceVersion = {
        major = "3";
        minor = "11";
        patch = "15";
        suffix = "";
      };
    };

    python312 = callPackage ./cpython {
      inherit passthruFun;
      hash = "sha256-wIvGWoGXHB3VeDGCgmUDNpRmx+ZzdNFkZRmt8FIHtoQ=";
      self = __splicedPackages.python312;

      sourceVersion = {
        major = "3";
        minor = "12";
        patch = "13";
        suffix = "";
      };
    };

    python313 = callPackage ./cpython {
      inherit passthruFun;
      hash = "sha256-Y55DJDxiCjCPloIT354A8vj2IzL3rbqnp+65eDBXxpA=";
      self = __splicedPackages.python313;

      sourceVersion = {
        major = "3";
        minor = "13";
        patch = "14";
        suffix = "";
      };
    };

    python314 = callPackage ./cpython (
      {
        inherit passthruFun;
        self = __splicedPackages.python314;
      }
      // sources.python314
    );

    python315 = callPackage ./cpython {
      inherit passthruFun;
      hash = "sha256-apNa4jSmfmVJiUNzsM/rg2EYLQOyFEIyiulZirdCISc=";
      self = __splicedPackages.python315;

      sourceVersion = {
        major = "3";
        minor = "15";
        patch = "0";
        suffix = "b3";
      };
    };

    # Minimal versions of Python (built without optional dependencies)
    python3Minimal =
      (callPackage ./cpython (
        {
          inherit passthruFun;
          pythonAttr = "python3Minimal";
          self = __splicedPackages.python3Minimal;
          # strip down that python version as much as possible
          withMinimalDeps = true;
        }
        // sources.python314
      )).overrideAttrs
        (old: {
          pname = "python3-minimal";
          # TODO(@Artturin): Add this to the main cpython expr
          strictDeps = true;
        });
  }
  // lib.optionalAttrs config.allowAliases {
    pypy39_prebuilt = throw "pypy 3.9 has been removed, use pypy 3.10 instead"; # Added 2025-01-03
  }
)
