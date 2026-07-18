{
  lib,
  armTrustedFirmwareTools,
  bzip2,
  cbfstool,
  fetchPypi,
  gzip,
  lz4,
  lzop,
  makeWrapper,
  openssl,
  python3Packages,
  ubootTools,
  vboot-utils,
  xilinx-bootgen,
  xz,
  zstd,
}:

let
  # We are fetching from PyPI because the code in the repository seems to be
  # lagging behind the PyPI releases somehow...
  version = "0.0.7";
in
rec {

  binman =
    let
      btools = [
        armTrustedFirmwareTools
        bzip2
        cbfstool
        # TODO: cst
        gzip
        lz4
        # TODO: lzma_alone
        lzop
        openssl
        ubootTools
        vboot-utils
        xilinx-bootgen
        xz
        zstd
      ];
    in
    python3Packages.buildPythonApplication rec {
      inherit version;
      pname = "binary_manager";

      src = fetchPypi {
        inherit pname version;
        hash = "sha256-llEBBhUoW5jTEQeoaTCjZN8y6Kj+PGNUSB3cKpgD06w=";
      };

      patches = [
        ./binman-resources.patch
      ];

      nativeBuildInputs = [ makeWrapper ];

      preFixup = ''
        wrapProgram "$out/bin/binman" --prefix PATH : "${lib.makeBinPath btools}"
      '';

      build-system = with python3Packages; [
        setuptools
      ];

      dependencies =
        (with python3Packages; [
          jsonschema
          pycryptodomex
          pyelftools
          yamllint
        ])
        ++ [
          dtoc
          u_boot_pylib
        ];

      patchFlags = [
        "-p2"
        "-d"
        "src"
      ];

      pyproject = true;
    };

  dtoc = python3Packages.buildPythonPackage rec {
    inherit version;
    pname = "dtoc";

    src = fetchPypi {
      inherit pname version;
      hash = "sha256-NA96CznIxjqpw2Ik8AJpJkJ/ei+kQTCUExwFgssV+CM=";
    };

    build-system = with python3Packages; [
      setuptools
    ];

    dependencies =
      (with python3Packages; [
        libfdt
      ])
      ++ [
        u_boot_pylib
      ];

    pyproject = true;
    pythonImportsCheck = [ "dtoc" ];
  };

  patman = python3Packages.buildPythonApplication rec {
    inherit version;
    pname = "patch_manager";

    src = fetchPypi {
      inherit pname version;
      hash = "sha256-zD9e87fpWKynpUcfxobbdk6wbM6Ja3f8hEVHS7DGIKQ=";
    };

    build-system = with python3Packages; [
      setuptools
    ];

    dependencies =
      (with python3Packages; [
        aiohttp
        pygit2
      ])
      ++ [
        u_boot_pylib
      ];

    pyproject = true;
  };

  u_boot_pylib = python3Packages.buildPythonPackage rec {
    inherit version;
    pname = "u_boot_pylib";

    src = fetchPypi {
      inherit pname version;
      hash = "sha256-A5r20Y8mgxhOhaKMpd5MJN5ubzPbkodAO0Tr0RN1SRA=";
    };

    checkPhase = ''
      ${python3Packages.python.interpreter} "src/$pname/__main__.py"
      # There are some tests in other files, but they are broken
    '';

    build-system = with python3Packages; [
      setuptools
    ];

    pyproject = true;
    pythonImportsCheck = [ "u_boot_pylib" ];
  };

}
