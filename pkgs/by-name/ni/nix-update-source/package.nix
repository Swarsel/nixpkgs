{
  lib,
  fetchFromGitHub,
  nix-prefetch-scripts,
  pkgs,
  python3Packages,
  runtimeShell,
}:

python3Packages.buildPythonApplication rec {
  pname = "nix-update-source";
  version = "0.7.0";

  src = fetchFromGitHub {
    owner = "timbertson";
    repo = "nix-update-source";
    rev = "version-${version}";
    hash = "sha256-+49Yb+rZ3CzFnwEpwj5xrcMUVBiYOJtCk9YeZ15IM/U=";
  };

  propagatedBuildInputs = [ nix-prefetch-scripts ];
  doCheck = false;
  format = "setuptools";

  passthru = {
    # NOTE: `fetch` should not be used within nixpkgs because it
    # uses a non-idiomatic structure. It is provided for use by
    # out-of-tree nix derivations.
    fetch =
      path:
      let
        fetchers = {
          # whitelist of allowed fetchers
          inherit (pkgs) fetchgit fetchurl fetchFromGitHub;
        };
        json = lib.importJSON path;
        fetchFn = builtins.getAttr json.fetch.fn fetchers;
        src = fetchFn json.fetch.args;
      in
      json
      // json.fetch
      // {
        inherit src;

        overrideSrc =
          drv:
          lib.overrideDerivation drv (orig: {
            inherit src;
          });
      };

    updateScript = [
      runtimeShell
      "-c"
      ''
        set -e
        echo
        cd ${toString ./.}
        ${pkgs.nix-update-source}/bin/nix-update-source \
          --prompt version \
          --replace-attr version \
          --set owner timbertson \
          --set repo nix-update-source \
          --set type fetchFromGitHub \
          --set rev 'version-{version}' \
          --nix-literal rev 'version-''${version}'\
          --modify-nix default.nix
      ''
    ];
  };

  meta = {
    description = "Utility to automate updating of nix derivation sources";
    homepage = "https://github.com/timbertson/nix-update-source";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ timbertson ];
    mainProgram = "nix-update-source";
  };
}
