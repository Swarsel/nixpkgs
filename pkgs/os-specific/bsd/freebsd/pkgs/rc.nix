{
  lib,
  bash,
  bin,
  devctl,
  devmatch,
  fsck,
  gnugrep,
  id,
  kldload,
  kldstat,
  logger,
  mkDerivation,
  mount,
  protect,
  rcorder,
  sed,
  sort,
  stat,
  sysctl,
}:
let
  rcDepsPath = lib.makeBinPath [
    sysctl
    bin
    bash
    rcorder
    stat
    id
    mount
    protect
    fsck
    logger
    devmatch
    sort
    kldload
    kldstat
    devctl
    sed
    gnugrep
  ];
in
mkDerivation {
  outputs = [
    "out"
    "services"
  ];

  postPatch = ''
    substituteInPlace "$BSDSRCDIR/libexec/rc/Makefile" \
      --replace-fail /etc $out/etc \
      --replace-fail /libexec $out/libexec
    substituteInPlace "$BSDSRCDIR/libexec/rc/rc.d/Makefile" \
      --replace-fail /etc $services/etc \
      --replace-fail /var $services/var
  ''
  + (
    let
      bins = {
        "/bin/cat" = bin;
        "/bin/chmod" = bin;
        "/bin/cpuset" = bin;
        "/bin/date" = bin;
        "/bin/ps" = bin;
        "/bin/rm" = bin;
        "/bin/sleep" = bin;
        "/bin/sync" = bin;
        "/sbin/sysctl" = sysctl;
        "/usr/bin/id" = id;
        "/usr/bin/logger" = logger;
        "/usr/bin/protect" = protect;
        "/usr/bin/stat" = stat;
        "kenv" = bin;
        "logger" = logger;
      };
      scripts = [
        "rc"
        "rc.initdiskless"
        "rc.shutdown"
        "rc.subr"
        "rc.suspend"
        "rc.resume"
        "rc.conf"
      ];
      scriptPaths = "$BSDSRCDIR/libexec/rc/{${lib.concatStringsSep "," scripts}}";
    in
    # set PATH correctly in scripts
    ''
      sed -E -i -e "s|PATH=.*|PATH=${rcDepsPath}|g" ${scriptPaths}
      sed -E -i -e "/etc\/rc.subr/i export PATH=${rcDepsPath}" $BSDSRCDIR/libexec/rc/rc.d/*
    ''
    # replace executable references with nix store filepaths
    + lib.concatMapStringsSep "\n" (
      {
        name,
        value,
        fname ? name,
      }:
      ''
        sed -E -i -e "s|${fname}|${lib.getBin value}/bin/${lib.last (lib.splitString "/" fname)}|g" \
          ${scriptPaths}''
    ) (lib.attrsToList bins)
    + "\n"
  );

  postInstall = ''
    makeFlags="$(sed -E -e 's/CONFDIR=[^ ]*//g' <<<"$makeFlags")"
    make $makeFlags installconfig
  '';

  MK_TESTS = "no";
  path = "libexec/rc";
  skipIncludesPhase = true;
}
