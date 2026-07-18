# Create a derivation that contains aspell and selected dictionaries.
# Composition is done using `pkgs.buildEnv`.
# Beware of that `ASPELL_CONF` used by this derivation is not always
# respected by libaspell (#28815) and in some cases, when used as
# dependency by another derivation, the passed dictionaries will be
# missing. However, invoking aspell directly should be fine.

{
  aspell,
  aspellDicts,
  buildEnv,
  makeWrapper,
}:

f:

let
  # Dictionaries we want
  dicts = f aspellDicts;

in
buildEnv {
  nativeBuildInputs = [ makeWrapper ];

  postBuild = ''
    # Construct wrappers in /bin
    unlink "$out/bin"
    mkdir -p "$out/bin"
    pushd "${aspell}/bin"
    for prg in *; do
      if [ -f "$prg" ]; then
        makeWrapper "${aspell}/bin/$prg" "$out/bin/$prg" --set ASPELL_CONF "dict-dir $out/lib/aspell; data-dir $out/lib/aspell"
      fi
    done
    popd
  '';

  name = "aspell-env";
  paths = [ aspell ] ++ dicts;
}
