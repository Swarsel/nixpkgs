{
  lib,
  stdenv,
  fetchFromGitLab,
  autoreconfHook,
  perl,
  po4a,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "debianutils";
  version = "5.23.2";

  src = fetchFromGitLab {
    owner = "debian";
    repo = "debianutils";
    rev = "debian/${finalAttrs.version}";
    hash = "sha256-28pl0uua4gX65uZP1td87HfojKLvkjJbo8KPqpgg/0g=";
    domain = "salsa.debian.org";
  };

  outputs = [
    "out"
    "man"
  ];

  strictDeps = true;

  nativeBuildInputs = [
    autoreconfHook
    perl
    po4a
  ];

  meta = {
    description = "Miscellaneous utilities specific to Debian";

    longDescription = ''
      This package provides a number of small utilities which are used primarily
      by the installation scripts of Debian packages, although you may use them
      directly.

      The specific utilities included are: add-shell installkernel ischroot
      remove-shell run-parts savelog tempfile which
    '';

    homepage = "https://packages.debian.org/sid/debianutils";

    license = with lib.licenses; [
      gpl2Plus
      publicDomain
      smail
    ];

    maintainers = [ ];
    platforms = lib.platforms.all;
    mainProgram = "ischroot";
  };
})
