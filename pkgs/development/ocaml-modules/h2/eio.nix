{
  buildDunePackage,
  eio,
  gluten-eio,
  h2,
}:

buildDunePackage {
  inherit (h2) src version;
  pname = "h2-eio";

  propagatedBuildInputs = [
    eio
    gluten-eio
    h2
  ];

  meta = h2.meta // {
    description = "EIO support for h2";
  };
}
