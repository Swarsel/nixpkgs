{
  lib,
  buildPecl,
  pkg-config,
  samba,
}:
buildPecl {
  pname = "smbclient";
  version = "1.1.2";
  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ samba ];
  # TODO: remove this when upstream merges a fix - https://github.com/eduardok/libsmbclient-php/pull/66
  env.LIBSMBCLIENT_INCDIR = "${samba.dev}/include/samba-4.0";
  sha256 = "sha256-Hmp0RWOqxwCBXlca2YsRNahOhA1E5qxnmXSUx4Cpzec=";

  meta = {
    description = "PHP wrapper for libsmbclient";
    homepage = "https://github.com/eduardok/libsmbclient-php";
    license = lib.licenses.bsd2;
    teams = [ lib.teams.php ];
  };
}
