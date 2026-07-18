{
  lib,
  dieHook,
  makeSetupHook,
}:

makeSetupHook {
  propagatedBuildInputs = [ dieHook ];
  name = "shorten-perl-shebang-hook";
  meta.license = lib.licenses.mit;
} ./shorten-perl-shebang.sh
