{
  lib,
  stdenv,
  perl,
}:
stdenv.mkDerivation {
  inherit perl;
  pname = "mono-dll-fixer";
  version = lib.trivial.release;

  installPhase = ''
    substitute $dllFixer $out --subst-var-by perl $perl/bin/perl
    chmod +x $out
  '';

  dllFixer = ./dll-fixer.pl;
  dontUnpack = true;
}
