{
  lib,
  stdenv,
  fetchurl,
  autoreconfHook,
  fetchDebianPatch,
  libice,
  libsm,
  libx11,
  libxt,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "x11-ssh-askpass";
  version = "1.2.4.1";

  src = fetchurl {
    url = "https://pkgs.fedoraproject.org/repo/pkgs/openssh/x11-ssh-askpass-${finalAttrs.version}.tar.gz/8f2e41f3f7eaa8543a2440454637f3c3/x11-ssh-askpass-${finalAttrs.version}.tar.gz";
    sha256 = "620de3c32ae72185a2c9aeaec03af24242b9621964e38eb625afb6cdb30b8c88";
  };

  outputs = [
    "out"
    "man"
  ];

  patches = [
    (fetchDebianPatch {
      pname = "ssh-askpass";
      version = "1:1.2.4.1";
      debianRevision = "16";
      hash = "sha256-S2tl0GeDia/ZuyXetPOsiu79kS9yLId7gUj3siw7pH4=";
      patch = "autotools.patch";
    })
  ];

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];

  buildInputs = [
    libx11
    libxt
    libice
    libsm
  ];

  meta = {
    description = "Lightweight passphrase dialog for OpenSSH or other open variants of SSH";
    homepage = "https://github.com/sigmavirus24/x11-ssh-askpass";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
  };
})
