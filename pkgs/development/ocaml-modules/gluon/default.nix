{
  lib,
  fetchurl,
  buildDunePackage,
  bytestring,
  config,
  fetchpatch,
  libc,
  rio,
  uri,
}:

buildDunePackage (finalAttrs: {
  pname = "gluon";
  version = "0.0.9";

  src = fetchurl {
    url = "https://github.com/riot-ml/gluon/releases/download/${finalAttrs.version}/gluon-${finalAttrs.version}.tbz";
    hash = "sha256-YWJCPokY1A7TGqCGoxJl14oKDVeMNybEEB7KiK92WSo=";
  };

  patches = fetchpatch {
    hash = "sha256-XuzyoteQAgEs93WrgHTWT1I+hIJAiGiJ4XAiLtnEYtw=";
    url = "https://github.com/riot-ml/gluon/commit/b29c34d04ea05d7721a229c35132320e796ed4b2.patch";
  };

  buildInputs = [
    config
  ];

  propagatedBuildInputs = [
    bytestring
    libc
    rio
    uri
  ];

  minimalOCamlVersion = "5.1";

  meta = {
    description = "Minimal, portable, and fast API on top of the operating-system's evented I/O API";
    homepage = "https://github.com/riot-ml/gluon";
    changelog = "https://github.com/riot-ml/gluon/blob/${finalAttrs.version}/CHANGES.md";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
})
