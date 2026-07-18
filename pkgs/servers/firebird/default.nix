{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  cmake,
  fetchDebianPatch,
  icu73,
  libedit,
  libtomcrypt,
  libtommath,
  unzip,
  zlib,
  superServer ? false,
}:

let
  base = {
    pname = "firebird";
    strictDeps = true;
    nativeBuildInputs = [ autoreconfHook ];

    buildInputs = [
      libedit
      icu73
    ];

    configureFlags = [
      "--with-system-editline"
    ]
    ++ (lib.optional superServer "--enable-superserver");

    env.LD_LIBRARY_PATH = lib.makeLibraryPath [ icu73 ];

    installPhase = ''
      runHook preInstall
      mkdir -p $out
      cp -r gen/Release/firebird/* $out
      rm -f $out/lib/*.a  # they were just symlinks to /build/source/...
      runHook postInstall
    '';

    __structuredAttrs = true;
    enableParallelBuilding = true;

    meta = {
      description = "SQL relational database management system";
      homepage = "https://firebirdsql.org/";
      changelog = "https://github.com/FirebirdSQL/firebird/blob/master/CHANGELOG.md";

      license = with lib.licenses; [
        mpl11
        interbase
      ];

      maintainers = with lib.maintainers; [
        bbenno
      ];

      platforms = lib.platforms.linux;
      downloadPage = "https://github.com/FirebirdSQL/firebird/";
    };

  };
in
rec {
  firebird = firebird_5;

  firebird_3 = stdenv.mkDerivation (
    base
    // rec {
      version = "3.0.14";

      src = fetchFromGitHub {
        owner = "FirebirdSQL";
        repo = "firebird";
        rev = "v${version}";
        hash = "sha256-X6Jv32VniAefIWjLTPwEipsQVRl7HBb4EKyi2IL1VWM=";
      };

      patches = [
        (fetchDebianPatch {
          pname = "firebird3.0";
          version = "3.0.13.ds7";
          debianRevision = "2";
          hash = "sha256-LXUMM38PBYeLPdgaxLPau4HWB4ItJBBnx7oGwalL6Pg=";
          patch = "no-binary-gbaks.patch";
        })
      ];

      buildInputs = base.buildInputs ++ [
        zlib
        libtommath
      ];

      meta = base.meta // {
        platforms = [ "x86_64-linux" ];
      };
    }
  );

  firebird_4 = stdenv.mkDerivation (
    base
    // rec {
      version = "4.0.7";

      src = fetchFromGitHub {
        owner = "FirebirdSQL";
        repo = "firebird";
        rev = "v${version}";
        hash = "sha256-4u1Vgwk5cMCkrGfGSk2xO7hVHiDda0ioitvX/r3KPQc=";
      };

      nativeBuildInputs = base.nativeBuildInputs ++ [ unzip ];

      buildInputs = base.buildInputs ++ [
        zlib
        libtommath
        libtomcrypt
      ];
    }
  );

  firebird_5 = stdenv.mkDerivation (
    base
    // rec {
      version = "5.0.4";

      src = fetchFromGitHub {
        owner = "FirebirdSQL";
        repo = "firebird";
        rev = "v${version}";
        hash = "sha256-IJrfs8q7GtX4Y+Cmg4avT5QJmLpld38tyR3TR1CcgyE=";
        fetchSubmodules = true;
      };

      nativeBuildInputs = base.nativeBuildInputs ++ [
        cmake
        unzip
      ];

      buildInputs = base.buildInputs ++ [
        zlib
        libtommath
        libtomcrypt
      ];

      # CMake is just used for libcds
      dontUseCmakeConfigure = true;
    }
  );
}
