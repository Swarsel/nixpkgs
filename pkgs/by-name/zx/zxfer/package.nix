{
  lib,
  fetchFromGitHub,
  bash,
  coreutils,
  gawk,
  gnugrep,
  gnused,
  installShellFiles,
  openssh,
  resholve,
  rsync,
  which,
  zfs,
}:

resholve.mkDerivation (finalAttrs: {
  pname = "zxfer";
  version = "1.1.7";

  src = fetchFromGitHub {
    owner = "allanjude";
    repo = "zxfer";
    rev = "v${finalAttrs.version}";
    hash = "sha256-11SQJcD3GqPYBIgaycyKkc62/diVKPuuj2Or97j+NZY=";
  };

  # these may point to paths on remote systems, calculated at runtime, thus we cannot fix them
  # we can only set their initial values, and let them remain dynamic
  postPatch = ''
    substituteInPlace zxfer \
      --replace 'LCAT=""'                'LCAT=${coreutils}/bin/cat' \
      --replace 'LZFS=$( which zfs )'    'LZFS=${zfs}/bin/zfs'
  '';

  nativeBuildInputs = [ installShellFiles ];

  installPhase = ''
    runHook preInstall

    installManPage zxfer.1m zxfer.8
    install -Dm755 zxfer -t $out/bin/

    runHook postInstall
  '';

  solutions.default = {
    execer = [ "cannot:${rsync}/bin/rsync" ];

    fake.external = [
      "kldload" # bsd builtin
      "kldstat" # bsd builtin
      "svcadm" # solaris builtin
    ];

    fix = {
      "$AWK" = [ "awk" ];
      "$RSYNC" = [ "rsync" ];
    };

    inputs = [
      coreutils
      gawk
      gnugrep
      gnused
      openssh
      rsync
      which
    ];

    interpreter = "${bash}/bin/sh";

    keep = {
      "$LCAT" = true;
      "$LZFS" = true;
      "$PROGRESS_DIALOG" = true;
      "$RZFS" = true;
      "$input_optionts" = true;
      "$option_O" = true;
      "$option_T" = true;
    };

    scripts = [ "bin/zxfer" ];
  };

  meta = {
    description = "Popular script for managing ZFS snapshot replication";
    homepage = "https://github.com/allanjude/zxfer";
    changelog = "https://github.com/allanjude/zxfer/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.bsd2;
    maintainers = [ ];
    mainProgram = "zxfer";
  };
})
