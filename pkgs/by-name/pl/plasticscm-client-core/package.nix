{
  buildFHSEnv,
  libgcc,
  libz,
  plasticscm-client-core-unwrapped,
  extraLibs ? _: [ ],
  extraPkgs ? _: [ ],
}:
buildFHSEnv {
  inherit (plasticscm-client-core-unwrapped) version meta;
  pname = "plasticscm-client-core";

  extraInstallCommands = ''
    mv $out/bin/plasticscm-client-core $out/bin/cm
  '';

  multiPkgs =
    pkgs:
    with pkgs;
    [
      # Dependencies from the Debian package
      glibc.out
      libgcc
      libz
      krb5.lib
      lttng-ust.out
      openssl_3.out
      icu76

      # Transitive dependencies from the Debian package
      libidn2.out
      libunistring
      e2fsprogs.out
      keyutils.lib
      numactl.out
    ]
    ++ extraLibs pkgs;

  runScript = "/usr/bin/cm";

  targetPkgs =
    pkgs:
    [
      plasticscm-client-core-unwrapped
    ]
    ++ extraPkgs pkgs;
}
