{
  lib,
  cacert,
  pijul,
  stdenvNoCC,
}:

lib.makeOverridable (
  {
    # Remote to fetch
    url,
    change ? null,
    channel ? "main",
    hash ? "",
    # Additional list of remotes specifying alternative download location to be
    # tried in order, if the prior remote failed to fetch.
    mirrors ? [ ],
    name ? "fetchpijul",
    state ? null,
    # TODO: Changes in pijul are unordered so there's many ways to end up with the same repository state.
    # This makes leaveDotPijul unfeasible to implement until pijul CLI implements
    # a way of reordering changes to sort them in a consistent and deterministic manner.
    # leaveDotPijul ? false
  }:
  if change != null && state != null then
    throw "Only one of 'change' or 'state' can be set"
  else
    stdenvNoCC.mkDerivation {
      inherit name;

      inherit
        change
        state
        channel
        ;

      strictDeps = true;

      nativeBuildInputs = [
        pijul
        cacert
      ];

      installPhase = ''
        runHook preInstall

        success=
        for remote in $remotes; do
          if
            pijul clone \
              ''${change:+--change "$change"} \
              ''${state:+--state "$state"} \
              --channel "$channel" \
              "$remote" \
              "$out"
          then
            success=1
            break
          fi
        done

        if [ -z "$success" ]; then
          echo "Error: couldn’t clone remote from any mirror" 1>&2
          exit 1
        fi

        runHook postInstall
      '';

      dontBuild = true;
      dontConfigure = true;
      dontUnpack = true;

      fixupPhase = ''
        runHook preFixup

        rm -rf "$out/.pijul"

        runHook postFixup
      '';

      impureEnvVars = lib.fetchers.proxyImpureEnvVars;
      outputHash = if hash != "" then hash else lib.fakeHash;
      outputHashAlgo = null;
      outputHashMode = "recursive";
      remotes = [ url ] ++ mirrors;
    }
)
