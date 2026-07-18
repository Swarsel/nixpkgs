{
  lib,
  fetchurl,
  buildDunePackage,
  cmdliner,
  dune-configurator,
  lwt,
  withLwt ? true,
}:

buildDunePackage (finalAttrs: {
  pname = "hxd";
  version = "0.5.0";

  src = fetchurl {
    url = "https://github.com/dinosaure/hxd/releases/download/v${finalAttrs.version}/hxd-${finalAttrs.version}.tbz";
    hash = "sha256-RTw5TsFWeMXObvEjVuTVgGoCYRdmAPrMp2XexBZx+qk=";
  };

  buildInputs = [
    cmdliner
    dune-configurator
  ];

  propagatedBuildInputs = lib.optional withLwt lwt;
  doCheck = true;

  preCheck = ''
    export DUNE_CACHE=disabled
  '';

  meta = {
    description = "Hexdump in OCaml";
    homepage = "https://github.com/dinosaure/hxd";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sternenseemann ];
    mainProgram = "hxd.xxd";
  };
})
