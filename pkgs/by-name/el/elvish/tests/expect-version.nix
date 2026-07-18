{
  stdenv,
  elvish,
  replaceVars,
}:

stdenv.mkDerivation {
  inherit (elvish) version;
  pname = "elvish-simple-test";
  nativeBuildInputs = [ elvish ];

  buildCommand = ''
    elvish ${
      replaceVars ./expect-version.elv {
        inherit (elvish) version;
      }
    }

    touch $out
  '';

  dontInstall = true;
  meta.timeout = 10;
}
