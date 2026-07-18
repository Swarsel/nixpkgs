{
  lib,
  stdenv,
  fetchFromGitHub,
  clang,
  fetchpatch,
  installShellFiles,
  libpcap,
  openssl,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "cowpatty";
  version = "4.8";

  src = fetchFromGitHub {
    owner = "joswr1ght";
    repo = "cowpatty";
    tag = finalAttrs.version;
    sha256 = "0fvwwghhd7wsx0lw2dj9rdsjnirawnq3c6silzvhi0yfnzn5fs0s";
  };

  patches = [
    # Pull upstream fix for parallel builds:
    #   https://github.com/joswr1ght/cowpatty/pull/5
    (fetchpatch {
      hash = "sha256-k0Qht80HcjvPoxVPF6wAXwxN3d2mxBrEyeFGuU7w9eA=";
      name = "fix-parallel.patch";
      url = "https://github.com/joswr1ght/cowpatty/commit/9c8cc09c4fa90aebee44afcd0ad6a35539178478.patch";
    })
  ];

  nativeBuildInputs = [
    clang
    installShellFiles
  ];

  buildInputs = [
    openssl
    libpcap
  ];

  makeFlags = [
    "DESTDIR=$(out)"
    "BINDIR=/bin"
  ];

  postInstall = ''
    installManPage cowpatty.1
    installManPage genpmk.1
  '';

  enableParallelBuilding = true;

  meta = {
    description = "Offline dictionary attack against WPA/WPA2 networks";
    homepage = "https://github.com/joswr1ght/cowpatty";
    license = lib.licenses.bsd3;

    maintainers = with lib.maintainers; [
      nico202
      fab
    ];

    platforms = lib.platforms.linux;
  };
})
