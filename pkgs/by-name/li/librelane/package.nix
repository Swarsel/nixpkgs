{
  lib,
  fetchFromGitHub,
  # wrapper runtime dependencies
  abc-verifier,
  klayout,
  magic-vlsi,
  # nativeBuildInputs
  makeWrapper,
  netgen-vlsi,
  nix-update-script,
  openroad,
  # dependencies
  pdk-ciel,
  python3Packages,
  ruby,
  verilator,
  yosys,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "librelane";
  version = "3.0.4";

  src = fetchFromGitHub {
    owner = "librelane";
    repo = "librelane";
    tag = finalAttrs.version;
    hash = "sha256-y1h2KEbK2rSn54uDuCfH9ouo2FLTFbVxpgOqnR+kwhM=";
  };

  nativeBuildInputs = [
    makeWrapper
  ];

  postInstall = ''
    # Create the site-packages subdirectory for librelane
    dest="$out/${python3Packages.python.sitePackages}/librelane"
    mkdir -p "$dest"

    # Copy scripts and examples from the source into the installation
    cp -r librelane/scripts "$dest/"
    cp -r librelane/examples "$dest/"
  '';

  postFixup = ''
    wrapProgram $out/bin/librelane \
      --suffix PYTHONPATH : "$PYTHONPATH" \
      --prefix PATH : ${
        lib.makeBinPath [
          abc-verifier
          klayout
          magic-vlsi
          netgen-vlsi
          openroad
          ruby
          verilator
          yosys
        ]
      }
  '';

  build-system = [
    python3Packages.poetry-core
  ];

  dependencies = with python3Packages; [
    click
    cloup
    deprecated
    httpx
    libparse-python
    lxml
    numpy
    pandas
    pdk-ciel
    psutil
    python3Packages.klayout
    pyyaml
    rapidfuzz
    rich
    semver
    tkinter
    yamlcore
  ];

  pyproject = true;

  pythonRelaxDeps = [
    "click"
  ];

  passthru = {
    updateScript = nix-update-script {
      extraArgs = [
        "--version-regex"
        "^([0-9.]+)$"
      ];
    };
  };

  meta = {
    description = "ASIC implementation flow infrastructure";
    homepage = "https://github.com/librelane/librelane";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.gonsolo ];
    mainProgram = "librelane";
  };
})
