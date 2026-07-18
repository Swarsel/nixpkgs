{
  lib,
  stdenv,
  fetchFromGitHub,
  amazon-ssm-agent,
  bashInteractive,
  buildGoModule,
  coreutils,
  darwin,
  dmidecode,
  makeWrapper,
  nix-update-script,
  nixosTests,
  substitute,
  testers,
  unixtools,
  util-linux,
  writeShellScriptBin,
}:

let
  # Tests use lsb_release, so we mock it (the SSM agent used to not
  # read from our /etc/os-release file, but now it does) because in
  # reality, it won't (shouldn't) be used when active on a system with
  # /etc/os-release. If it is, we fake the only two fields it cares about.
  fake-lsb-release = writeShellScriptBin "lsb_release" ''
    . /etc/os-release || true

    case "$1" in
      -i) echo "''${NAME:-unknown}";;
      -r) echo "''${VERSION:-unknown}";;
    esac
  '';

  binaries = {
    "agent" = "ssm-agent-worker";
    "cli-main" = "ssm-cli";
    "core" = "amazon-ssm-agent";
    "logging" = "ssm-session-logger";
    "sessionworker" = "ssm-session-worker";
    "worker" = "ssm-document-worker";
  };
in
buildGoModule (finalAttrs: {
  pname = "amazon-ssm-agent";
  version = "3.3.4515.0";

  src = fetchFromGitHub {
    owner = "aws";
    repo = "amazon-ssm-agent";
    tag = finalAttrs.version;
    hash = "sha256-FEYziTgYIzX8tm/zgVDi2Tvbxn+lBnXAAqqO+LhlQYM=";
  };

  patches = [
    # Some tests use networking, so we skip them.
    ./0001-Disable-NIC-tests-that-fail-in-the-Nix-sandbox.patch

    # They used constants from another package that I couldn't figure
    # out how to resolve, so hardcoded the constants.
    ./0002-version-gen-don-t-use-unnecessary-constants.patch

    # They run a tool on the build platform in a way that isn't quite
    # compatible with cross (`go run`). Simplest thing is to just make
    # the file with a hardcoded value, as we already have it from attrs.
    (substitute {
      src = ./0001-makefile-don-t-use-tool-to-generate-version-file.patch;

      substitutions = [
        "--subst-var-by"
        "VERSION"
        finalAttrs.version
      ];
    })
  ];

  postPatch = ''
    printf "#!/bin/sh\ntrue" > ./Tools/src/checkstyle.sh

    substituteInPlace agent/platform/platform_unix.go \
      --replace-fail "/usr/bin/uname" "${coreutils}/bin/uname" \
      --replace-fail '"/bin", "hostname"' '"${unixtools.hostname}/bin/hostname"' \
      --replace-fail '"lsb_release"' '"${fake-lsb-release}/bin/lsb_release"'

    substituteInPlace agent/session/shell/shell_unix.go \
      --replace-fail '"script"' '"${util-linux}/bin/script"'

    substituteInPlace agent/rebooter/rebooter_unix.go \
      --replace-fail "/sbin/shutdown" "shutdown"

    echo "${finalAttrs.version}" > VERSION
  ''
  + lib.optionalString stdenv.hostPlatform.isLinux ''
    substituteInPlace agent/managedInstances/fingerprint/hardwareInfo_unix.go \
      --replace-fail /usr/sbin/dmidecode ${dmidecode}/bin/dmidecode
  '';

  nativeBuildInputs = [
    makeWrapper
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    darwin.DarwinTools
  ];

  vendorHash = null;

  preBuild = ''
    make pre-release
    make pre-build
  '';

  doCheck = false;

  installPhase = ''
    runHook preInstall

    declare -A map=(${
      builtins.concatStringsSep " " (
        lib.mapAttrsToList (name: value: "[\"${name}\"]=\"${value}\"") binaries
      )
    })

    for key in ''${!map[@]}; do
      install -D -m 0555 -T "$GOPATH/bin/''${key}" "$out/bin/''${map[''${key}]}"
    done

    # These templates retain their `.template` extensions on installation. The
    # amazon-ssm-agent.json.template is required as default configuration when an
    # amazon-ssm-agent.json isn't present. Here, we retain the template to show
    # we're using the default configuration.

    # seelog.xml isn't actually required to run, but it does ship as a template
    # with debian packages, so it's here for reference. Future work in the nixos
    # module could use this template and substitute a different log level.

    install -D -m 0444 -t $out/etc/amazon/ssm amazon-ssm-agent.json.template
    install -D -m 0444 -T seelog_unix.xml $out/etc/amazon/ssm/seelog.xml.template

    runHook postInstall
  '';

  postFixup = ''
    wrapProgram $out/bin/amazon-ssm-agent \
      --prefix PATH : "${lib.makeBinPath [ bashInteractive ]}"
  '';

  __darwinAllowLocalNetworking = true;

  ldflags = [
    "-s"
    "-w"
  ];

  # See the list https://github.com/aws/amazon-ssm-agent/blob/3.2.2143.0/makefile#L121-L147
  # The updater is not built because it cannot work on NixOS
  subPackages = [
    "core"
    "agent"
    "agent/cli-main"
    "agent/framework/processor/executer/outofproc/sessionworker"
    "agent/framework/processor/executer/outofproc/worker"
    "agent/session/logging"
  ];

  passthru = {
    tests = {
      inherit (nixosTests) amazon-ssm-agent;

      version = testers.testVersion {
        command = "amazon-ssm-agent --version";
        package = amazon-ssm-agent;
      };
    };

    updateScript = nix-update-script { };
  };

  meta = {
    description = "Agent to enable remote management of your Amazon EC2 instance configuration";
    homepage = "https://github.com/aws/amazon-ssm-agent";
    changelog = "https://github.com/aws/amazon-ssm-agent/releases/tag/${finalAttrs.version}";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      anthonyroussel
      arianvp
    ];

    platforms = lib.platforms.unix;
  };
})
