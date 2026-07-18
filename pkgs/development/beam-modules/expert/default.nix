{
  lib,
  fetchFromGitHub,
  _experimental-update-script-combinators,
  erlang,
  fetchMixDeps,
  gnused,
  mixRelease,
  nix-update-script,
  nurl,
  writeShellApplication,
}:
let
  version = "0.1.6";

  src = fetchFromGitHub {
    owner = "expert-lsp";
    repo = "expert";
    tag = "v${version}";
    hash = "sha256-25ADJtvwZ5hkS9+x9BYsPDnvXIXU+UV+3CoIpFJkziA=";
  };

  engineDeps = fetchMixDeps {
    inherit src version;
    pname = "mix-deps-expert-engine";

    preConfigure = ''
      cd apps/engine
    '';

    hash = "sha256-evYg/yRk6ymV75kuWpY0pFODWWopozjnFHUa9MOFN/A=";
  };
in
mixRelease rec {
  inherit src version;
  pname = "expert";

  preConfigure = ''
    ln -sv ${engineDeps} apps/engine/deps

    cd apps/expert
  '';

  postInstall = ''
    mv $out/bin/plain $out/bin/expert

    wrapProgram $out/bin/expert --add-flag "eval" --add-flag "System.no_halt(true); Application.ensure_all_started(:xp_expert)"
  '';

  mixFodDeps = fetchMixDeps {
    inherit src version;
    pname = "mix-deps-${pname}";

    preConfigure = ''
      cd apps/expert
    '';

    hash = "sha256-N2krs4NNWytrN3K8lR5IGGroXVNuBzjks6IoD9D1rPM=";
  };

  mixReleaseName = "plain";
  removeCookie = false;

  passthru = {
    inherit engineDeps;

    updateScript = _experimental-update-script-combinators.sequence [
      (nix-update-script { })
      (lib.getExe (writeShellApplication {
        name = "expert-update-engine";

        runtimeInputs = [
          gnused
          nurl
        ];

        text = ''
          nixpkgs="$(git rev-parse --show-toplevel)"
          engineHashOld=${engineDeps.hash}
          engineHashNew=$(nurl -e "(import $nixpkgs/. { }).$UPDATE_NIX_ATTR_PATH.engineDeps")
          echo "$UPDATE_NIX_ATTR_PATH.engineDeps.hash" >&2
          sed -i "s|$engineHashOld|$engineHashNew|" "$nixpkgs"/pkgs/development/beam-modules/expert/default.nix
        '';
      }))
    ];
  };

  meta = {
    inherit (erlang.meta) platforms;
    description = "Official Elixir Language Server Protocol implementation";

    longDescription = ''
      Expert is the official language server implementation for the Elixir programming language.
    '';

    homepage = "https://github.com/expert-lsp/expert";
    changelog = "https://github.com/expert-lsp/expert/blob/v0.1.1/CHANGELOG.md";
    license = lib.licenses.asl20;
    mainProgram = "expert";
    teams = [ lib.teams.beam ];
  };
}
