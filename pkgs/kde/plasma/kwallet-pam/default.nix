{
  lib,
  libgcrypt,
  mkKdeDerivation,
  pam,
  pkg-config,
  socat,
}:
mkKdeDerivation {
  pname = "kwallet-pam";

  postPatch = ''
    sed -i pam_kwallet_init -e "s|socat|${lib.getBin socat}/bin/socat|"
  '';

  extraBuildInputs = [
    pam
    libgcrypt
  ];

  extraNativeBuildInputs = [ pkg-config ];
}
