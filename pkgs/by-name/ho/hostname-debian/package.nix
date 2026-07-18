{
  lib,
  stdenv,
  fetchFromGitLab,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "hostname-debian";
  version = "3.25";

  src = fetchFromGitLab {
    owner = "meskes";
    repo = "hostname";
    tag = "debian/${finalAttrs.version}";
    hash = "sha256-Yq8P5bF/RRZnWuFW0y2u08oZrydAKfopOtbrwbeIu3w=";
    domain = "salsa.debian.org";
  };

  outputs = [
    "out"
    "man"
  ];

  makeFlags = [
    "prefix=${placeholder "out"}"
  ];

  meta = {
    description = "Utility to set/show the host name or domain name";

    longDescription = ''
      This package provides commands which can be used to display the system's
      DNS name, and to display or set its hostname or NIS domain name.
    '';

    homepage = "https://tracker.debian.org/pkg/hostname";
    changelog = "https://salsa.debian.org/meskes/hostname/-/blob/${finalAttrs.src.tag}/debian/changelog";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ posch ];
    platforms = lib.platforms.gnu;
    mainProgram = "hostname";
  };
})
