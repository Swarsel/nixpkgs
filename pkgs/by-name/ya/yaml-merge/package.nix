{
  lib,
  stdenv,
  fetchFromGitHub,
  pkgsHostTarget,
  python3Packages,
}:

stdenv.mkDerivation {
  pname = "yaml-merge";
  version = "0-unstable-2022-01-12";

  src = fetchFromGitHub {
    owner = "abbradar";
    repo = "yaml-merge";
    rev = "2f0174fe92fc283dd38063a3a14f7fe71db4d9ec";
    sha256 = "sha256-S2eZw+FOZvOn0XupZDRNcolUPd4PhvU1ziu+kx2AwnY=";
  };

  nativeBuildInputs = [
    # Not `python3Packages.wrapPython` to workaround `python3Packages.wrapPython.__spliced.buildHost` having the wrong `pythonHost`
    # See https://github.com/NixOS/nixpkgs/issues/434307
    pkgsHostTarget.python3Packages.wrapPython
  ];

  installPhase = ''
    install -Dm755 yaml-merge.py $out/bin/yaml-merge
    wrapPythonPrograms
  '';

  pythonPath = with python3Packages; [ pyyaml ];

  meta = {
    description = "Merge YAML data files";
    homepage = "https://github.com/abbradar/yaml-merge";
    license = lib.licenses.bsd2;
    maintainers = [ ];
    platforms = lib.platforms.unix;
    mainProgram = "yaml-merge";
  };
}
