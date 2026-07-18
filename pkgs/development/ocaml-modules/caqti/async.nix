{
  async_kernel,
  async_unix,
  buildDunePackage,
  caqti,
  core_kernel,
}:

buildDunePackage {
  inherit (caqti) version src;
  pname = "caqti-async";

  propagatedBuildInputs = [
    async_kernel
    async_unix
    caqti
    core_kernel
  ];

  minimalOCamlVersion = "5.0";

  meta = caqti.meta // {
    description = "Async support for Caqti";
  };
}
