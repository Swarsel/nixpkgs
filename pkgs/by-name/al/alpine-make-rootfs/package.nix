{
  lib,
  fetchFromGitHub,
  apk-tools,
  coreutils,
  findutils,
  gnugrep,
  gnused,
  gnutar,
  gzip,
  makeWrapper,
  rsync,
  stdenvNoCC,
  util-linux,
  wget,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "alpine-make-rootfs";
  version = "0.8.1";

  src = fetchFromGitHub {
    owner = "alpinelinux";
    repo = "alpine-make-rootfs";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ktGJXPJK94RbdqcgsA3fA8+MO0inaRcwaDLx18KFo1w=";
  };

  nativeBuildInputs = [ makeWrapper ];
  makeFlags = [ "PREFIX=$(out)" ];

  postInstall = ''
    wrapProgram $out/bin/alpine-make-rootfs --set PATH ${
      lib.makeBinPath [
        apk-tools
        coreutils
        findutils
        gnugrep
        gnused
        gnutar
        gzip
        rsync
        util-linux
        wget
      ]
    }
  '';

  dontBuild = true;

  meta = {
    description = "Make customized Alpine Linux rootfs (base image) for containers";
    homepage = "https://github.com/alpinelinux/alpine-make-rootfs";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ danielsidhion ];
    platforms = lib.platforms.linux;
    mainProgram = "alpine-make-rootfs";
  };
})
