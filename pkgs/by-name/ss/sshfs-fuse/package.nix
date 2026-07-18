{
  lib,
  stdenv,
  fetchFromGitHub,
  docutils,
  fuse3,
  glib,
  macfuse-stubs,
  makeWrapper,
  meson,
  ninja,
  openssh,
  pkg-config,
  python3Packages,
  which,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "sshfs-fuse";
  version = "3.7.6";

  src = fetchFromGitHub {
    owner = "libfuse";
    repo = "sshfs";
    tag = "sshfs-${finalAttrs.version}";
    hash = "sha256-BT9qttXyryliR2kV1xVYvcwJhB6gkGf7IEwrTB38SvI=";
  };

  outputs = [
    "out"
    "man"
  ];

  nativeBuildInputs = [
    meson
    pkg-config
    ninja
    docutils
    makeWrapper
  ];

  buildInputs = [
    fuse3
    glib
  ];

  env.NIX_CFLAGS_COMPILE = lib.optionalString (
    stdenv.hostPlatform.system == "i686-linux"
  ) "-D_FILE_OFFSET_BITS=64";

  nativeCheckInputs = [
    which
    python3Packages.pytest
  ];

  # doCheck = true;
  checkPhase = lib.optionalString (!stdenv.hostPlatform.isDarwin) ''
    # The tests need fusermount:
    mkdir bin
    cp ${fuse3}/bin/fusermount3 bin/fusermount
    export PATH=bin:$PATH
    # Can't access /dev/fuse within the sandbox: "FUSE kernel module does not seem to be loaded"
    substituteInPlace test/util.py --replace "/dev/fuse" "/dev/null"
    # TODO: "fusermount executable not setuid, and we are not root"
    # We should probably use a VM test instead
    ${python3Packages.python.interpreter} -m pytest test/
  '';

  postInstall = ''
    mkdir -p $out/sbin
    ln -sf $out/bin/sshfs $out/sbin/mount.sshfs
  ''
  + lib.optionalString (!stdenv.hostPlatform.isDarwin) ''
    wrapProgram $out/bin/sshfs --prefix PATH : "${openssh}/bin"
  '';

  meta = {
    description = "FUSE-based filesystem that allows remote filesystems to be mounted over SSH";
    longDescription = macfuse-stubs.warning;
    homepage = "https://github.com/libfuse/sshfs";
    changelog = "https://github.com/libfuse/sshfs/blob/${finalAttrs.src.tag}/ChangeLog.rst";
    license = lib.licenses.gpl2Plus;
    maintainers = [ ];
    platforms = lib.platforms.darwin ++ lib.platforms.linux;
    mainProgram = "sshfs";
  };
})
