{
  lib,
  fetchurl,
  buildDunePackage,
  ctypes,
  ctypes-foreign,
  dune-configurator,
  libargon2,
  result,
}:

buildDunePackage (finalAttrs: {
  pname = "argon2";
  version = "1.0.2";

  src = fetchurl {
    url = "https://github.com/Khady/ocaml-argon2/releases/download/${finalAttrs.version}/argon2-${finalAttrs.version}.tbz";
    hash = "sha256-NDsOV4kPT2SnSfNHDBAK+VKZgHDIKxW+dNJ/C5bQ8gU=";
  };

  buildInputs = [
    dune-configurator
  ];

  propagatedBuildInputs = [
    ctypes
    ctypes-foreign
    libargon2
    result
  ];

  minimalOCamlVersion = "4.02.3";

  meta = {
    description = "Ocaml bindings to Argon2";
    homepage = "https://github.com/Khady/ocaml-argon2";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ naora ];
  };
})
