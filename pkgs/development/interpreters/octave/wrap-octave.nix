{
  lib,
  makeSetupHook,
  makeWrapper,
  octave,
}:

# Defined in trivial-builders
# Imported as wrapOctave in octave/default.nix and passed to octave's buildEnv
# as nativeBuildInput
# Each of the substitutions is available in the wrap.sh script as @thingSubstituted@
makeSetupHook {
  propagatedBuildInputs = [ makeWrapper ];
  name = "${octave.name}-pkgs-setup-hook";
  substitutions.executable = octave.interpreter;
  substitutions.octave = octave;
  meta.license = lib.licenses.mit;
} ./wrap.sh
