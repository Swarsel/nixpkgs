{
  buildDunePackage,
  dune-configurator,
  posix-base,
}:

buildDunePackage {
  inherit (posix-base) version src;
  pname = "posix-socket";
  buildInputs = [ dune-configurator ];
  propagatedBuildInputs = [ posix-base ];
  doCheck = true;
  minimalOCamlVersion = "4.12";

  meta = posix-base.meta // {
    description = "Bindings for posix sockets";
  };

}
