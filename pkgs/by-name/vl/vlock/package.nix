{
  lib,
  stdenv,
  fetchurl,
  pam,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "vlock";
  version = "2.2.2";

  src = fetchurl {
    url = "mirror://debian/pool/main/v/vlock/vlock_${finalAttrs.version}.orig.tar.gz";
    sha256 = "1b9gv7hmlb8swda5bn40lp1yki8b8wv29vdnhcjqfl6ir98551za";
  };

  patches = [ ./eintr.patch ];
  buildInputs = [ pam ];

  configureFlags = [
    "VLOCK_GROUP=root"
    "ROOT_GROUP=root"
  ];

  prePatch = ''
    sed -i -e '/INSTALL/ {
      s/-[og] [^ ]*//g; s/4711/755/
    }' Makefile modules/Makefile
  '';

  meta = {
    description = "Virtual console locking program";
    license = lib.licenses.gpl2Only;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "vlock";
  };
})
