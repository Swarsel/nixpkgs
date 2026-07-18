{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  callPackage,
  libffi,
  libiconv,
  libxml2,
  llvm,
  ncurses,
  pythonAtLeast,
  rustPlatform,
  zlib,
}:

let
  common =
    {
      buildAndTestSubdir,
      cargoHash,
      pname,
      extraBuildInputs ? [ ],
      extraNativeBuildInputs ? [ ],
    }:
    buildPythonPackage rec {
      inherit pname;
      inherit buildAndTestSubdir;
      version = "1.2.0";

      src = fetchFromGitHub {
        owner = "wasmerio";
        repo = "wasmer-python";
        rev = version;
        hash = "sha256-Iu28LMDNmtL2r7gJV5Vbb8HZj18dlkHe+mw/Y1L8YKE=";
      };

      outputs = [ "out" ] ++ lib.optional (pname == "wasmer") "testsout";

      postPatch = ''
        # Workaround for metadata, that maturin 0.14 does not accept in Cargo.toml anymore
        substituteInPlace ${buildAndTestSubdir}/Cargo.toml \
          --replace "package.metadata.maturin" "broken"
      '';

      nativeBuildInputs =
        (with rustPlatform; [
          cargoSetupHook
          maturinBuildHook
        ])
        ++ extraNativeBuildInputs;

      buildInputs = lib.optionals stdenv.hostPlatform.isDarwin [ libiconv ] ++ extraBuildInputs;
      # check in passthru.tests.pytest because all packages are required to run the tests
      doCheck = false;

      postInstall = lib.optionalString (pname == "wasmer") ''
        mkdir $testsout
        cp -R tests $testsout/tests
      '';

      cargoDeps = rustPlatform.fetchCargoVendor {
        inherit pname version src;
        hash = cargoHash;
      };

      pyproject = true;
      pythonImportsCheck = [ "${lib.replaceStrings [ "-" ] [ "_" ] pname}" ];
      passthru.tests = lib.optionalAttrs (pname == "wasmer") { pytest = callPackage ./tests.nix { }; };

      meta = {
        description = "Python extension to run WebAssembly binaries";
        homepage = "https://github.com/wasmerio/wasmer-python";
        license = lib.licenses.mit;
        maintainers = [ ];
        platforms = lib.platforms.unix;
        # https://github.com/wasmerio/wasmer-python/issues/778
        broken = pythonAtLeast "3.12";
      };
    };
in
{
  wasmer = common {
    pname = "wasmer";
    cargoHash = "sha256-oHyjzEqv88e2CHhWhKjUh6K0UflT9Y1JD//3oiE/UBQ=";
    buildAndTestSubdir = "packages/api";
  };

  wasmer-compiler-cranelift = common {
    pname = "wasmer-compiler-cranelift";
    cargoHash = "sha256-oHyjzEqv88e2CHhWhKjUh6K0UflT9Y1JD//3oiE/UBQ=";
    buildAndTestSubdir = "packages/compiler-cranelift";
  };

  wasmer-compiler-llvm = common {
    pname = "wasmer-compiler-llvm";
    cargoHash = "sha256-oHyjzEqv88e2CHhWhKjUh6K0UflT9Y1JD//3oiE/UBQ=";
    buildAndTestSubdir = "packages/compiler-llvm";

    extraBuildInputs = [
      libffi
      libxml2.out
      ncurses
      zlib
    ];

    extraNativeBuildInputs = [ llvm ];
  };

  wasmer-compiler-singlepass = common {
    pname = "wasmer-compiler-singlepass";
    cargoHash = "sha256-oHyjzEqv88e2CHhWhKjUh6K0UflT9Y1JD//3oiE/UBQ=";
    buildAndTestSubdir = "packages/compiler-singlepass";
  };
}
