{
  lib,
  stdenv,
  fetchurl,
  gettext,
  libselinux,
  libsemanage,
  libsepol,
  libxcrypt,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  inherit (libsepol) se_url;
  pname = "policycoreutils";
  version = "3.11";

  src = fetchurl {
    url = "${finalAttrs.se_url}/${finalAttrs.version}/policycoreutils-${finalAttrs.version}.tar.gz";
    hash = "sha256-BU5B7AOXMaXua3l6jguNbjRu4dCpusLyUttIwj+aixs=";
  };

  postPatch = ''
    # Fix install references
    substituteInPlace po/Makefile \
       --replace /usr/bin/install install --replace /usr/share /share
    substituteInPlace newrole/Makefile --replace /usr/share /share
  '';

  nativeBuildInputs = [
    gettext
    pkg-config
  ];

  buildInputs = [
    libsepol
    libselinux
    libsemanage
    libxcrypt
  ];

  makeFlags = [
    "PREFIX=$(out)"
    "SBINDIR=$(out)/bin"
    "ETCDIR=$(out)/etc"
    "BASHCOMPLETIONDIR=$out/share/bash-completion/completions"
    "LOCALEDIR=$(out)/share/locale"
    "MAN5DIR=$(out)/share/man/man5"
  ];

  meta = {
    inherit (libsepol.meta) homepage platforms maintainers;
    description = "SELinux policy core utilities";
    license = lib.licenses.gpl2Only;
  };
})
