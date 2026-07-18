{
  lib,
  stdenv,
  fetchzip,
  libressl,
  pkg-config,
  sqlite,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "litterbox";
  version = "1.9";

  src = fetchzip {
    url = "https://git.causal.agency/litterbox/snapshot/litterbox-${finalAttrs.version}.tar.gz";
    hash = "sha256-w4qW7J5CKm+hXHsNNbl9roBslHD14JOe0Nj5WntETqM=";
  };

  strictDeps = true;
  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    libressl
    sqlite
  ];

  buildFlags = [ "all" ];

  meta = {
    description = "Simple TLS-only IRC logger";
    homepage = "https://code.causal.agency/june/litterbox";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ ajwhouse ];
    platforms = lib.platforms.linux;
    mainProgram = "litterbox";
  };
})
