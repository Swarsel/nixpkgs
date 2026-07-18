{
  lib,
  fetchurl,
  buildDunePackage,
  lwt,
}:

buildDunePackage (finalAttrs: {
  pname = "lwt-dllist";
  version = "1.0.1";

  src = fetchurl {
    url = "https://github.com/mirage/lwt-dllist/releases/download/v${finalAttrs.version}/lwt-dllist-v${finalAttrs.version}.tbz";
    hash = "sha256-6GznXkDwDVFRTPiy5x5RhMTLXa6WE2viRhNAbPwNum4=";
  };

  doCheck = true;

  checkInputs = [
    lwt
  ];

  meta = {
    description = "Mutable doubly-linked list with Lwt iterators";
    homepage = "https://github.com/mirage/lwt-dllist";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sternenseemann ];
  };
})
