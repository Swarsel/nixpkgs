{
  lib,
  stdenv,
  applyPatches,
  bintrans,
  bsdSetupHook,
  buildPackages,
  config,
  ctfconvert,
  ctfmerge,
  dtc,
  file2c,
  filterSource,
  freebsd-lib,
  freebsdSetupHook,
  gawk,
  groff,
  install,
  kldxref,
  makeMinimal,
  mandoc,
  mkDerivation,
  patchesRoot,
  rpcgen,
  writeText,
  xargs-j,
  baseConfig ? "GENERIC",
  extraConfig ? null,
  extraFlags ? { },
}:
let
  baseConfigFile =
    if (extraConfig == null) then
      null
    else if (lib.isDerivation extraConfig) || (lib.isPath extraConfig) then
      extraConfig
    else
      writeText "extraConfig" extraConfig;
  hostMachineBsd = freebsd-lib.mkBsdMachine stdenv;
  filteredSource = filterSource {
    pname = "sys";
    extraPaths = [ "include" ];
    path = "sys";
  };
  patchedSource = applyPatches {
    src = filteredSource;

    patches = freebsd-lib.filterPatches patchesRoot [
      "sys"
      "include"
    ];

    postPatch = ''
      for f in sys/contrib/dev/acpica/acpica_prep.sh; do
        substituteInPlace "$f" --replace-warn 'xargs -J' 'xargs-j '
      done

      for f in sys/conf/*.mk; do
        substituteInPlace "$f" --replace-quiet 'KERN_DEBUGDIR}''${' 'KERN_DEBUGDIR_'
      done
    ''
    + lib.optionalString (baseConfigFile != null) ''
      cat ${baseConfigFile} >>sys/${hostMachineBsd}/conf/${baseConfig}
    '';
  };

  # Kernel modules need this for kern.opts.mk
  env = lib.flip lib.mapAttrs' extraFlags (
    name: value: {
      name = "MK_${lib.toUpper name}";
      value = lib.boolToYesNo value;
    }
  );
in
mkDerivation rec {
  inherit env;
  pname = "sys";
  # Patch source outside of this derivation so out-of-tree modules can use it
  src = patchedSource;

  outputs = [
    "out"
    "debug"
  ];

  nativeBuildInputs = [
    bsdSetupHook
    mandoc
    groff
    gawk
    freebsdSetupHook
    makeMinimal
    install
    config
    rpcgen
    file2c
    bintrans
    xargs-j
    kldxref
    ctfconvert
    ctfmerge
  ]
  # Device trees are built in the same sys package
  ++ lib.optional (stdenv.hostPlatform.isAarch32 || stdenv.hostPlatform.isAarch64) dtc;

  makeFlags = [ "XARGS_J=xargs-j" ];

  preBuild = ''
    cd ../compile/${baseConfig}
  '';

  AWK = "${buildPackages.gawk}/bin/awk";
  CWARNEXTRA = "-Wno-error=shift-negative-value -Wno-address-of-packed-member";
  DTBDIR = "${placeholder "out"}/dtb";
  DTBODIR = "${placeholder "out"}/dtb/overlays";
  KERN_DEBUGDIR = "${placeholder "debug"}/lib/debug";
  KERN_DEBUGDIR_KMODDIR = "${KERN_DEBUGDIR}/kernel";
  KERN_DEBUGDIR_KODIR = "${KERN_DEBUGDIR}/kernel";
  KMODDIR = "${placeholder "out"}/kernel";
  KODIR = "${placeholder "out"}/kernel";

  # hardeningDisable = stackprotector doesn't seem to be enough, put it in cflags too
  NIX_CFLAGS_COMPILE = [
    "-fno-stack-protector"
    "-Wno-unneeded-internal-declaration" # some openzfs code trips this
    "-Wno-default-const-init-field-unsafe" # added in clang 21
    "-Wno-uninitialized-const-pointer" # added in clang 21
    "-Wno-format" # error: passing 'printf' format string where 'freebsd_kprintf' format string is expected
    "-Wno-sometimes-uninitialized" # this one is actually kind of concerning but it does trip
    "-Wno-unused-function"
  ];

  # --dynamic-linker /red/herring is used when building the kernel.
  NIX_ENFORCE_PURITY = 0;
  autoPickPatches = false;

  configurePhase = ''
    runHook preConfigure

    cd ${hostMachineBsd}/conf
    config ${baseConfig}

    runHook postConfigure
  '';

  hardeningDisable = [
    "pic" # generates relocations the linker can't handle
    "stackprotector" # generates stack protection for the function generating the stack canary
  ];

  path = "sys";
  skipIncludesPhase = true;
  passthru.env = env;

  meta = {
    description = "FreeBSD kernel and modules";
    platforms = lib.platforms.freebsd;
  };
}
