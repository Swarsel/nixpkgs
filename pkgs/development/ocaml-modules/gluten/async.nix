{
  async,
  buildDunePackage,
  core,
  faraday-async,
  gluten,
}:

buildDunePackage {
  inherit (gluten) src version;
  pname = "gluten-async";

  propagatedBuildInputs = [
    gluten
    async
    faraday-async
    core
  ];

  meta = gluten.meta // {
    description = "Async support for gluten";
  };
}
