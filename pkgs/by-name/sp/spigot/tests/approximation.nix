{
  stdenv,
  spigot,
}:

stdenv.mkDerivation {
  inherit (spigot) version;
  pname = "spigot-approximation";
  nativeBuildInputs = [ spigot ];

  buildCommand = ''
    [ "$(spigot -b2 -d32 '(pi/1-355/113)')" = "-0.00000000000000000000010001111001" ]
    [ "$(spigot -b2 -d32 '(e/1-1457/536)')" = "-0.00000000000000000001110101101011" ]
    touch $out
  '';

  dontInstall = true;
  meta.timeout = 10;
}
