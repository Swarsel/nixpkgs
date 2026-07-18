{
  lib,
  stdenv,
  fetchFromGitLab,
  autoreconfHook,
  krb5,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libgssglue";
  version = "0.9";

  src = fetchFromGitLab {
    owner = "gsasl";
    repo = "libgssglue";
    rev = "tags/libgssglue-${finalAttrs.version}";
    hash = "sha256-p9dujLklv2ZC1YA1gKGCRJf9EvF3stv5v4Z/5m1nSeM=";
  };

  postPatch = ''
    touch ChangeLog

    sed s:/etc/gssapi_mech.conf:$out/etc/gssapi_mech.conf: -i src/g_initialize.c
  '';

  nativeBuildInputs = [ autoreconfHook ];

  postInstall = ''
    mkdir -p $out/etc
    cat <<EOF > $out/etc/gssapi_mech.conf
    ${lib.getLib krb5}/lib/libgssapi_krb5.so mechglue_internal_krb5_init
    EOF
  '';

  meta = {
    description = "Exports a gssapi interface which calls other random gssapi libraries";
    homepage = "http://www.citi.umich.edu/projects/nfsv4/linux/";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ corngood ];
    platforms = lib.platforms.linux;
  };
})
