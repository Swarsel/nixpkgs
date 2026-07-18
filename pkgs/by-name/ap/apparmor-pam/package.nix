{
  stdenv,
  # apparmor deps
  libapparmor,
  pam,
  pkg-config,
  which,
}:
stdenv.mkDerivation {
  inherit (libapparmor)
    version
    src
    ;

  pname = "apparmor-pam";

  postPatch = ''
    substituteInPlace Makefile \
      --replace-fail "pkg-config" "$PKG_CONFIG"
  '';

  nativeBuildInputs = [
    pkg-config
    which
  ];

  buildInputs = [
    libapparmor
    pam
  ];

  makeFlags = [ "USE_SYSTEM=1" ];
  installFlags = [ "DESTDIR=$(out)" ];
  sourceRoot = "${libapparmor.src.name}/changehat/pam_apparmor";

  meta = libapparmor.meta // {
    description = "Mandatory access control system - PAM service";
  };
}
