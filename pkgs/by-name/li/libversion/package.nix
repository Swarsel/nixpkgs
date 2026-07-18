{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libversion";
  version = "3.0.4";

  src = fetchFromGitHub {
    owner = "repology";
    repo = "libversion";
    rev = finalAttrs.version;
    hash = "sha256-USgSwAdRHEepq9ZTDHVWkPsZjljfh9sEWOZRfu0H7Go=";
  };

  nativeBuildInputs = [ cmake ];
  doCheck = true;
  checkTarget = "test";

  meta = {
    description = "Advanced version string comparison library";
    homepage = "https://github.com/repology/libversion";
    license = with lib.licenses; [ mit ];
    maintainers = with lib.maintainers; [ ryantm ];
    platforms = lib.platforms.unix;
  };
})
