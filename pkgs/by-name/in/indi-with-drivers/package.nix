{
  lib,
  buildEnv,
  makeBinaryWrapper,
  extraDrivers ? [ ],
  indilib ? indilib,
  pname ? "indi-with-drivers",
  version ? indilib.version,
}:

buildEnv {
  inherit (indilib) meta;
  nativeBuildInputs = [ makeBinaryWrapper ];

  postBuild = lib.optionalString (extraDrivers != [ ]) ''
    rm $out/bin/indiserver
    makeBinaryWrapper ${indilib}/bin/indiserver $out/bin/indiserver --set-default INDIPREFIX $out
  '';

  name = "${pname}-${version}";
  paths = [ indilib ] ++ extraDrivers;
}
