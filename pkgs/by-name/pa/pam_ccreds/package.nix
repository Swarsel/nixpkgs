{
  lib,
  stdenv,
  fetchurl,
  db,
  openssl,
  pam,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "pam_ccreds";
  version = "10";

  src = fetchurl {
    url = "https://www.padl.com/download/pam_ccreds-${finalAttrs.version}.tar.gz";
    sha256 = "1h7zyg1b1h69civyvrj95w22dg0y7lgw3hq4gqkdcg35w1y76fhz";
  };

  buildInputs = [
    pam
    openssl
    db
  ];

  patchPhase = ''
    sed 's/-o root -g root//' -i Makefile.in
  '';

  meta = {
    description = "PAM module to locally authenticate using an enterprise identity when the network is unavailable";
    homepage = "https://www.padl.com/OSS/pam_ccreds.html";
    license = lib.licenses.gpl2Only;
    platforms = lib.platforms.linux;
    mainProgram = "ccreds_chkpwd";
  };
})
