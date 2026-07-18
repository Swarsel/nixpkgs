{
  lib,
  stdenv,
  fetchFromGitHub,
  callPackage,
  # Runtime dependencies
  coreutils,
  dmidecode,
  gnugrep,
  inetutils,
  # Dependencies
  ipmitool,
  openssh,
  pciutils,
  perl,
  procps,
  replaceVars,
  rpm,
  util-linux,
  xterm,
}:

let
  inherit (lib) getExe getExe' genAttrs;

  # Define tool dependencies for script patches
  scriptDeps =
    let
      mkTools = pkg: tools: genAttrs tools (tool: getExe' pkg tool);
    in
    # Tools from various packages
    (mkTools coreutils [
      "cat"
      "whoami"
      "pwd"
      "uname"
      "date"
      "mkdir"
      "chown"
      "chgrp"
      "echo"
      "kill"
      "cd"
      "stty"
    ])
    // (mkTools util-linux [ "renice" ])
    // (mkTools gnugrep [
      "grep"
      "egrep"
    ])
    // (mkTools inetutils [
      "hostname"
      "ping"
    ])
    // (mkTools procps [ "ps" ])
    // (mkTools pciutils [ "lspci" ])
    // (mkTools xterm [ "resize" ])
    // (mkTools dmidecode [ "dmidecode" ])
    // (mkTools rpm [ "rpm" ])
    // {
      ipmitool = getExe ipmitool;
      # Single-tool packages
      ssh = getExe openssh;
    };
in

stdenv.mkDerivation (finalAttrs: {
  pname = "collectl";
  version = "4.3.20.3";

  src = fetchFromGitHub {
    owner = "sharkcz";
    repo = "collectl";
    rev = finalAttrs.version;
    hash = "sha256-hokovb6uqPiMFlDS0g2F/J1rHTkyNBegcgOC3g3ykEs=";
  };

  patches = [
    (replaceVars ./0001-scripts-external-executable-calls.patch scriptDeps)
    ./0002-fix-install-script.patch
  ];

  strictDeps = true;

  buildInputs = [
    perl
    dmidecode
    ipmitool
  ];

  installPhase = ''
    runHook preInstall

    bash ./INSTALL

    runHook postInstall
  '';

  dontBuild = true;
  passthru.tests.run = callPackage ./test.nix { };

  meta = {
    description = "Performance monitoring tool for Linux systems";

    longDescription = ''
      Collectl is a light-weight performance monitoring tool capable of reporting
      interactively as well as logging to disk. It reports statistics on cpu, disk,
      infiniband, lustre, memory, network, nfs, process, quadrics, slabs and more
      in easy to read format.

      The `--config` option allows specifying a custom configuration file path,
      overriding the default configuration file in the package's etc directory.
    '';

    homepage = "https://github.com/sharkcz/collectl";

    license = with lib.licenses; [
      artistic1
      gpl1Plus
    ];

    maintainers = with lib.maintainers; [ seven_bear ];
    platforms = lib.platforms.linux;
    mainProgram = "collectl";
    downloadPage = "https://github.com/sharkcz/collectl/releases";
  };
})
