{
  lib,
  stdenv,
  fetchFromGitHub,
  apk-tools,
  coreutils,
  dosfstools,
  e2fsprogs,
  findutils,
  gnugrep,
  gnused,
  kmod,
  makeWrapper,
  qemu-utils,
  rsync,
  util-linux,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "alpine-make-vm-image";
  version = "0.13.4";

  src = fetchFromGitHub {
    owner = "alpinelinux";
    repo = "alpine-make-vm-image";
    tag = "v${finalAttrs.version}";
    hash = "sha256-U3eJ9wOxxbC9gEDBMXanBmEy0x6YBSsXXf6U5nzVoZ8=";
  };

  nativeBuildInputs = [ makeWrapper ];
  makeFlags = [ "PREFIX=$(out)" ];

  postInstall = ''
    wrapProgram $out/bin/alpine-make-vm-image --set PATH ${
      lib.makeBinPath [
        apk-tools
        coreutils
        dosfstools
        e2fsprogs
        findutils
        gnugrep
        gnused
        kmod
        qemu-utils
        rsync
        util-linux
      ]
    }
  '';

  dontBuild = true;

  meta = {
    description = "Make customized Alpine Linux disk image for virtual machines";
    homepage = "https://github.com/alpinelinux/alpine-make-vm-image";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ wegank ];
    platforms = lib.platforms.unix;
    mainProgram = "alpine-make-vm-image";
  };
})
