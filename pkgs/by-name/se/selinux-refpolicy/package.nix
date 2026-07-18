{
  lib,
  stdenv,
  fetchFromGitHub,
  checkpolicy,
  getopt,
  gnum4,
  policycoreutils,
  python3,
  semodule-utils,
  moduleVersion ? null,
  policyVersion ? null,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "selinux-refpolicy";
  version = "2.20250923";

  src = fetchFromGitHub {
    owner = "SELinuxProject";
    repo = "refpolicy";
    tag = "RELEASE_${lib.versions.major finalAttrs.version}_${lib.versions.minor finalAttrs.version}";
    hash = "sha256-A7bC/44Swt1pe9qAubrOIVEJpsXeCkJUaftLHqq3EmM=";
  };

  nativeBuildInputs = [
    gnum4
    python3
    getopt
  ];

  makeFlags = [
    "CHECKPOLICY=${lib.getExe checkpolicy}"
    "CHECKMODULE=${lib.getExe' checkpolicy "checkmodule"}"
    "SEMODULE=${lib.getExe' policycoreutils "semodule"}"
    "SEMOD_PKG=${lib.getExe' semodule-utils "semodule_package"}"
    "SEMOD_LNK=${lib.getExe' semodule-utils "semodule_link"}"
    "SEMOD_EXP=${lib.getExe' semodule-utils "semodule_expand"}"
    "DESTDIR=${placeholder "out"}"
    "prefix=${placeholder "out"}"
    "DISTRO=nixos"
    "SYSTEMD=y"
    "UBAC=y"
  ]
  ++ lib.optional (policyVersion != null) "OUTPUT_POLICY=${toString policyVersion}"
  ++ lib.optional (moduleVersion != null) "OUTPUT_MODULE=${toString moduleVersion}";

  configurePhase = ''
    runHook preConfigure
    make conf ''${makeFlags[@]}
    runHook postConfigure
  '';

  installTargets = "all install install-headers install-docs";

  meta = {
    inherit (semodule-utils.meta) maintainers;
    description = "SELinux Reference Policy v2";
    homepage = "http://userspace.selinuxproject.org";
    license = lib.licenses.gpl2Only;
    platforms = lib.platforms.linux;
  };
})
