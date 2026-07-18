# Dependencies (callPackage)
{
  lib,
  shellcheck,
  stdenvNoCC,
}:

# testers.shellcheck function
# Docs: doc/build-helpers/testers.chapter.md
# Tests: ./tests.nix
{
  src,
  name ? null,
}:
stdenvNoCC.mkDerivation {
  inherit src;
  strictDeps = true;
  nativeBuildInputs = [ shellcheck ];
  doCheck = true;

  checkPhase = ''
    find "$src" -type f -print0 | xargs -0 shellcheck --source-path="$src"
  '';

  installPhase = ''
    touch "$out"
  '';

  __structuredAttrs = true;
  dontBuild = true;
  dontConfigure = true;
  dontUnpack = true; # Unpack phase tries to extract an archive, which we don't want to do with source trees

  name =
    if name == null then
      lib.warn "testers.shellcheck: name will be required in a future release, defaulting to run-shellcheck" "run-shellcheck"
    else
      "shellcheck-${name}";
}
