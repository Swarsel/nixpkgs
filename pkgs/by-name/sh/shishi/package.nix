{
  lib,
  stdenv,
  fetchurl,
  gnutls,
  libgcrypt,
  libgpg-error,
  libidn,
  libtasn1,
  pam,
  pkg-config,
  useGnutls ? lib.meta.availableOn stdenv.hostPlatform gnutls,
  useLibidn ? lib.meta.availableOn stdenv.hostPlatform libidn,
  # Optional Dependencies
  usePam ? lib.meta.availableOn stdenv.hostPlatform pam && stdenv.hostPlatform.isLinux,
}:

let
  inherit (lib) enableFeature withFeature optionalString;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "shishi";
  version = "1.0.3";

  src = fetchurl {
    url = "mirror://gnu/shishi/shishi-${finalAttrs.version}.tar.gz";
    hash = "sha256-lXmP/RLdAaT4jgMR7gPKSibly05ekFmkDk/E2fKRfpI=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    libgcrypt
    pkg-config
  ];

  buildInputs = [
    libgcrypt
    libgpg-error
    libtasn1
  ]
  ++ lib.optionals usePam [
    pam
  ]
  ++ lib.optionals useLibidn [
    libidn
  ]
  ++ lib.optionals useGnutls [
    gnutls
  ];

  configureFlags = [
    "--sysconfdir=/etc"
    "--localstatedir=/var"
    (enableFeature true "libgcrypt")
    (enableFeature usePam "pam")
    (enableFeature true "ipv6")
    (withFeature useLibidn "stringprep")
    (enableFeature useGnutls "starttls")
    (enableFeature true "des")
    (enableFeature true "3des")
    (enableFeature true "aes")
    (enableFeature true "md")
    (enableFeature false "null")
    (enableFeature true "arcfour")
  ];

  env.NIX_CFLAGS_COMPILE = optionalString stdenv.hostPlatform.isDarwin "-DBIND_8_COMPAT";
  doCheck = true;

  # Fix *.la files
  postInstall = ''
    sed -i $out/lib/libshi{sa,shi}.la \
  ''
  + optionalString useLibidn ''
    -e 's,\(-lidn\),-L${libidn.out}/lib \1,' \
  ''
  + optionalString useGnutls ''
    -e 's,\(-lgnutls\),-L${gnutls.out}/lib \1,' \
  ''
  + ''
    -e 's,\(-lgcrypt\),-L${libgcrypt.out}/lib \1,' \
    -e 's,\(-lgpg-error\),-L${libgpg-error.out}/lib \1,' \
    -e 's,\(-ltasn1\),-L${libtasn1.out}/lib \1,'
  '';

  installFlags = [ "sysconfdir=\${out}/etc" ];
  separateDebugInfo = true;

  meta = {
    description = "Implementation of the Kerberos 5 network security system";
    homepage = "https://www.gnu.org/software/shishi/";
    license = lib.licenses.gpl3Plus;
    maintainers = [ ];
    platforms = lib.platforms.linux;
  };
})
