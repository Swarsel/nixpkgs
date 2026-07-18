{
  gpgmepp,
  kdoctools,
  libgcrypt,
  libsecret,
  mkKdeDerivation,
  pkg-config,
}:
mkKdeDerivation {
  pname = "kwallet";

  extraBuildInputs = [
    gpgmepp
    libgcrypt
    libsecret
    kdoctools
  ];

  extraNativeBuildInputs = [
    pkg-config
  ];
}
