{
  lib,
  fetchurl,
  buildDunePackage,
  dune-configurator,
  libpq,
  pkg-config,
}:

buildDunePackage (finalAttrs: {
  pname = "postgresql";
  version = "5.2.0";

  src = fetchurl {
    url = "https://github.com/mmottl/postgresql-ocaml/releases/download/${finalAttrs.version}/postgresql-${finalAttrs.version}.tbz";
    hash = "sha256-uU/K7hvQljGnUzClPRdod32tpVAGd/sGqh3NqIygJ4A=";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ dune-configurator ];
  propagatedBuildInputs = [ libpq ];
  minimalOCamlVersion = "4.12";

  meta = {
    description = "Bindings to the PostgreSQL library";
    homepage = "https://mmottl.github.io/postgresql-ocaml";
    changelog = "https://raw.githubusercontent.com/mmottl/postgresql-ocaml/refs/tags/${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.lgpl21Plus;
    maintainers = with lib.maintainers; [ bcc32 ];
  };
})
