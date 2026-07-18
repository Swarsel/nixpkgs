{
  lib,
  buildPythonApplication,
  makeWrapper,
  # optional
  neovim-unwrapped,
  nix,
  nix-prefetch-git,
  nix-prefetch-github,
  nurl,
  python3Packages,
}:
buildPythonApplication {
  pname = "vim-plugins-updater";
  version = "0.1";

  nativeBuildInputs = [
    makeWrapper
    python3Packages.wrapPython
  ];

  installPhase = ''
    mkdir -p $out/bin $out/lib
    cp ${./update.py} $out/bin/vim-plugins-updater
    cp ${./get-plugins.nix} $out/bin/get-plugins.nix

    # wrap python scripts
    makeWrapperArgs+=( --prefix PATH : "${
      lib.makeBinPath [
        nix
        nix-prefetch-github
        nix-prefetch-git
        neovim-unwrapped
        nurl
      ]
    }" --prefix PYTHONPATH : "${lib.sources.sourceByGlobs ./. [ "**/*.py" ]}" )
    wrapPythonPrograms
  '';

  dontUnpack = true;
  pyproject = false;

  pythonPath = [
    python3Packages.requests
    python3Packages.nixpkgs-plugin-update
  ];

  shellHook = ''
    export PYTHONPATH=pkgs/applications/editors/vim/plugins:$PYTHONPATH
  '';

  meta.mainProgram = "vim-plugins-updater";
}
