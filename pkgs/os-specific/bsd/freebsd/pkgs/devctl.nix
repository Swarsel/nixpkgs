{
  libdevctl,
  mkDerivation,
}:
mkDerivation {
  outputs = [
    "out"
    "debug"
  ];

  buildInputs = [ libdevctl ];
  path = "usr.sbin/devctl";
  meta.mainProgram = "devctl";
}
