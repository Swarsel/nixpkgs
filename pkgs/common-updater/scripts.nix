{
  lib,
  stdenv,
  coreutils,
  diffutils,
  git,
  gnugrep,
  gnused,
  jq,
  makeWrapper,
  nix,
  python3Packages,
}:

stdenv.mkDerivation {
  nativeBuildInputs = [
    makeWrapper
    python3Packages.wrapPython
  ];

  installPhase = ''
    mkdir -p $out/bin
    cp ${./scripts}/* $out/bin

    # wrap non python scripts
    for f in $out/bin/*; do
      if ! (head -n1 "$f" | grep -q '#!.*/env.*\(python\|pypy\)'); then
        wrapProgram $f --prefix PATH : ${
          lib.makeBinPath [
            coreutils
            diffutils
            git
            gnugrep
            gnused
            jq
            nix
          ]
        }
      fi
    done

    # wrap python scripts
    makeWrapperArgs+=( --prefix PATH : "${lib.makeBinPath [ nix ]}" )
    wrapPythonPrograms
  '';

  dontUnpack = true;
  name = "common-updater-scripts";

  pythonPath = [
    python3Packages.beautifulsoup4
    python3Packages.requests
  ];
}
