{
  lib,
  fetchurl,
  bash,
  binutils,
  coreutils,
  file,
  findutils,
  gawk,
  glibc,
  gnugrep,
  gnused,
  net-tools,
  openssh,
  postgresql,
  ps,
  resholve,
  util-linux,
  which,
}:

resholve.mkDerivation (finalAttrs: {
  pname = "unix-privesc-check";
  version = "1.4";

  src = fetchurl {
    url = "https://pentestmonkey.net/tools/unix-privesc-check/unix-privesc-check-${finalAttrs.version}.tar.gz";
    hash = "sha256-4fhef2n6ut0jdWo9dqDj2GSyHih2O2DOLmGBKQ0cGWk=";
  };

  patches = [
    ./unix-privesc-check.patch # https://github.com/NixOS/nixpkgs/pull/287629#issuecomment-1944428796
  ];

  installPhase = ''
    runHook preInstall
    install -Dm 755 unix-privesc-check $out/bin/unix-privesc-check
    runHook postInstall
  '';

  solutions = {
    unix-privesc-check = {
      execer = [
        "cannot:${glibc.bin}/bin/ldd"
        "cannot:${postgresql}/bin/psql"
        "cannot:${openssh}/bin/ssh-add"
        "cannot:${util-linux.bin}/bin/swapon"
      ];

      fake = {
        external = [
          "lanscan" # lanscan exists only for HP-UX OS
          "mount" # Getting same error described in https://github.com/abathur/resholve/issues/29
          "passwd" # Getting same error described in https://github.com/abathur/resholve/issues/29
        ];
      };

      inputs = [
        gawk
        bash
        binutils # for strings command
        coreutils
        file
        findutils # for xargs command
        glibc # for ldd command
        gnugrep
        gnused
        net-tools
        openssh
        postgresql # for psql command
        ps
        util-linux # for swapon command
        which
      ];

      interpreter = "${bash}/bin/bash";
      scripts = [ "bin/unix-privesc-check" ];
    };
  };

  meta = {
    description = "Find misconfigurations that could allow local unprivilged users to escalate privileges to other users or to access local apps";
    homepage = "https://pentestmonkey.net/tools/audit/unix-privesc-check";
    license = lib.licenses.gpl2Plus;
    maintainers = [ ];
    platforms = lib.platforms.unix;
    mainProgram = "unix-privesc-check";
  };
})
