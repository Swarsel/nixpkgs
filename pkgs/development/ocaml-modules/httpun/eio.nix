{
  buildDunePackage,
  gluten-eio,
  httpun,
}:

buildDunePackage {
  inherit (httpun) src version;
  pname = "httpun-eio";

  propagatedBuildInputs = [
    gluten-eio
    httpun
  ];

  meta = httpun.meta // {
    description = "EIO support for httpun";
  };
}
