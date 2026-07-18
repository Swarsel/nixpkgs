{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  e2fsprogs,
  libselinux,
  libuuid,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "nilfs-utils";
  version = "2.2.12";

  src = fetchFromGitHub {
    owner = "nilfs-dev";
    repo = "nilfs-utils";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-9IUuam5g24+eywEeNZET8TAvKJVevJBwHTHSwN9Tz58=";
  };

  outputs = [
    "out"
    "man"
    "dev"
  ];

  postPatch = ''
    # Fix up hardcoded paths.
    substituteInPlace lib/cleaner_exec.c --replace /sbin/ $out/bin/
    substituteInPlace sbin/mkfs/mkfs.c --replace /sbin/ ${lib.getBin e2fsprogs}/bin/
  '';

  nativeBuildInputs = [ autoreconfHook ];

  buildInputs = [
    libuuid
    libselinux
  ];

  # According to upstream, libmount should be detected automatically but the
  # build system fails to do this. This is likely a bug with their build system
  # hence it is explicitly enabled here.
  configureFlags = [ "--with-libmount" ];

  # FIXME: https://github.com/NixOS/patchelf/pull/98 is in, but stdenv
  # still doesn't use it
  #
  # To make sure patchelf doesn't mistakenly keep the reference via
  # build directory
  postInstall = ''
    find . -name .libs -exec rm -rf -- {} +
  '';

  installFlags = [
    "sysconfdir=${placeholder "out"}/etc"
    "root_sbindir=${placeholder "out"}/sbin"
  ];

  meta = {
    description = "NILFS utilities";
    homepage = "https://github.com/nilfs-dev/nilfs-utils";

    license = with lib.licenses; [
      gpl2Plus
      lgpl21
    ];

    maintainers = [ lib.maintainers.raskin ];
    platforms = lib.platforms.linux;
    downloadPage = "http://nilfs.sourceforge.net/en/download.html";
  };
})
