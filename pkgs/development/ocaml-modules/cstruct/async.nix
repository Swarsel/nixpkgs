{
  async,
  async_unix,
  buildDunePackage,
  core,
  cstruct,
}:

buildDunePackage {
  inherit (cstruct) src version meta;
  pname = "cstruct-async";

  propagatedBuildInputs = [
    async_unix
    async
    cstruct
    core
  ];

  duneVersion = "3";
}
