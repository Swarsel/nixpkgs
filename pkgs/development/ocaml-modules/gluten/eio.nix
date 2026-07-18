{
  buildDunePackage,
  eio,
  gluten,
}:

buildDunePackage {
  inherit (gluten) src version;
  pname = "gluten-eio";

  propagatedBuildInputs = [
    gluten
    eio
  ];

  meta = gluten.meta // {
    description = "EIO runtime for gluten";
  };
}
