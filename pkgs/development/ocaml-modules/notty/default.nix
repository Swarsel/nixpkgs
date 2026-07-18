{
  lib,
  fetchurl,
  buildDunePackage,
  cppo,
  fetchpatch,
  lwt,
  uutf,
}:

buildDunePackage (finalAttrs: {
  pname = "notty";
  version = "0.2.3";

  src = fetchurl {
    url = "https://github.com/pqwy/notty/releases/download/v${finalAttrs.version}/notty-${finalAttrs.version}.tbz";
    sha256 = "sha256-dGWfsUBz20Q4mJiRqyTyS++Bqkl9rBbZpn+aHJwgCCQ=";
  };

  # Compatibility with OCaml 5.4
  patches = fetchpatch {
    hash = "sha256-p1eUuCvQKLj8uBeGyT2+i9WOYy4rk84pf9L3QioJDNY=";
    url = "https://github.com/pqwy/notty/commit/a4d62f467e257196a5192da2184bd021dfd948b7.patch";
  };

  nativeBuildInputs = [ cppo ];

  propagatedBuildInputs = [
    lwt
    uutf
  ];

  minimalOCamlVersion = "4.08";

  meta = {
    description = "Declarative terminal graphics for OCaml";
    homepage = "https://github.com/pqwy/notty";
    license = lib.licenses.isc;
    maintainers = with lib.maintainers; [ sternenseemann ];
  };
})
