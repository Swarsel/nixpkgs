{
  lib,
  stdenv,
  fetchFromGitHub,
  audit,
  bash,
  bashNonInteractive,
  buildPackages,
  db4,
  docbook5,
  docbook_xsl_ns,
  fetchpatch,
  findXMLCatalogs,
  flex,
  gettext,
  libxcrypt,
  libxml2,
  libxslt,
  linuxHeaders,
  meson,
  ninja,
  nix-update-script,
  nixosTests,
  pkg-config,
  systemdLibs,
  w3m-batch,
  debugMode ? false, # warning: slower execution due to debug makes VM tests fail!
  withAudit ?
    lib.meta.availableOn stdenv.hostPlatform audit
    # cross-compilation only works from platforms with linux headers
    && lib.meta.availableOn stdenv.buildPlatform linuxHeaders,
  withLogind ? lib.meta.availableOn stdenv.hostPlatform systemdLibs,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "linux-pam";
  version = "1.7.2";

  src = fetchFromGitHub {
    owner = "linux-pam";
    repo = "linux-pam";
    tag = "v${finalAttrs.version}";
    hash = "sha256-V3XQqolinh+MqUefMDYJF9zP4fBJTHc7YKN+NEGjx1g=";
  };

  outputs = [
    "out"
    "doc"
    "man"
    "scripts"
    # "modules"
  ];

  patches = [
    (fetchpatch {
      hash = "sha256-ddgDYdVfdXfTaMFV1hO3RJX9w1NHmE7yi3PxsHOdpvY=";
      name = "secure-opendir-fix-error-handling.patch";
      url = "https://github.com/linux-pam/linux-pam/commit/dd62bac17221911106de165607c6925ea54b18d1.patch?full_index=1";
    })
  ];

  # patching unix_chkpwd is required as the nix store entry does not have the necessary bits
  postPatch = ''
    substituteInPlace modules/module-meson.build \
      --replace-fail "sbindir / 'unix_chkpwd'" "'/run/wrappers/bin/unix_chkpwd'"
  '';

  strictDeps = true;

  nativeBuildInputs = [
    flex
    meson
    ninja
    pkg-config
    gettext

    libxslt
    libxml2
    w3m-batch
    findXMLCatalogs
    docbook_xsl_ns
    docbook5
  ];

  buildInputs = [
    db4
    libxcrypt
    bash
  ]
  ++ lib.optionals withAudit [
    audit
  ]
  ++ lib.optionals withLogind [
    systemdLibs
  ];

  mesonFlags = [
    (lib.mesonEnable "logind" withLogind)
    (lib.mesonEnable "audit" withAudit)
    (lib.mesonEnable "pam_lastlog" (!stdenv.hostPlatform.isMusl)) # TODO: switch to pam_lastlog2, pam_lastlog is deprecated and broken on musl
    (lib.mesonEnable "pam_unix" true)
    (lib.mesonOption "sysconfdir" "etc") # relative to meson prefix, which is $out
    (lib.mesonEnable "elogind" false)
    (lib.mesonEnable "econf" false)
    (lib.mesonEnable "selinux" false)
    (lib.mesonEnable "nis" false)
    (lib.mesonBool "xtests" false)
    (lib.mesonBool "examples" false)
    (lib.mesonOption "vendordir" "${placeholder "out"}/etc")
  ]
  # warning: slower execution due to debug makes VM tests fail!
  ++ lib.optional debugMode (lib.mesonBool "pam-debug" true);

  doCheck = false; # fails

  postInstall = ''
    moveToOutput sbin/pam_namespace_helper $scripts
    moveToOutput etc/security/namespace.init $scripts
  '';

  __structuredAttrs = true;
  depsBuildBuild = [ buildPackages.stdenv.cc ];
  enableParallelBuilding = true;
  mesonAutoFeatures = "auto";

  outputChecks.out.disallowedRequisites = [
    bash
    bashNonInteractive
  ];

  passthru = {
    tests = {
      inherit (nixosTests)
        pam-oath-login
        pam-u2f
        pam-lastlog
        shadow
        sssd-ldap
        ;
    };

    updateScript = nix-update-script { };
  };

  meta = {
    description = "Pluggable Authentication Modules, a flexible mechanism for authenticating user";
    homepage = "https://github.com/linux-pam/linux-pam";
    changelog = "https://github.com/linux-pam/linux-pam/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.bsd3;
    platforms = lib.platforms.linux;
    badPlatforms = [ lib.systems.inspect.platformPatterns.isStatic ];
    identifiers.cpeParts = lib.meta.cpeFullVersionWithVendor "linux-pam" finalAttrs.version;
  };
})
