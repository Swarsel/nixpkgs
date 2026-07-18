{
  lib,
  stdenv,
  fetchurl,
  guile,
  guile-fibers,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gnu-shepherd";
  version = "1.0.9";

  src = fetchurl {
    url = "mirror://gnu/shepherd/shepherd-${finalAttrs.version}.tar.gz";
    hash = "sha256-5IjFhchBjfbo9HbcqBtykQ8zfJzTYI+0Z95SYABAANY=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    guile
    guile-fibers
  ];

  configureFlags = [ "--localstatedir=/" ];

  meta = {
    description = "Service manager that looks after the herd of system services";
    homepage = "https://www.gnu.org/software/shepherd/";
    license = with lib.licenses; [ gpl3Plus ];
    maintainers = with lib.maintainers; [ kloenk ];
    platforms = lib.platforms.unix;
  };
})
