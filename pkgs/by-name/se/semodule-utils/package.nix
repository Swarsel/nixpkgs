{
  lib,
  stdenv,
  fetchurl,
  libsepol,
}:

stdenv.mkDerivation (finalAttrs: {
  inherit (libsepol) se_url;
  pname = "semodule-utils";
  version = "3.11";

  src = fetchurl {
    url = "${finalAttrs.se_url}/${finalAttrs.version}/semodule-utils-${finalAttrs.version}.tar.gz";
    hash = "sha256-DFdOFUE/9+1mDEXgEb7+JIu4nqonPbb1brKX1h3rLtY=";
  };

  buildInputs = [ libsepol ];

  makeFlags = [
    "PREFIX=$(out)"
    "LIBSEPOLA=${lib.getLib libsepol}/lib/libsepol.a"
  ];

  meta = {
    inherit (libsepol.meta) homepage platforms maintainers;
    description = "SELinux policy core utilities (packaging additions)";
    license = lib.licenses.gpl2Only;
  };
})
