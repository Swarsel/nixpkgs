{
  lib,
  stdenv,
  fetchFromGitHub,
  ethtool,
  help2man,
  inetutils,
  iperf,
  iproute2,
  makeWrapper,
  net-tools,
  python3,
  runCommand,
  socat,
  which,
}:

let
  pyEnv = python3.withPackages (ps: [
    ps.setuptools
    ps.packaging
    ps.distutils
  ]);

  telnet = runCommand "inetutils-telnet" { } ''
    mkdir -p "$out/bin"
    ln -s "${inetutils}"/bin/telnet "$out/bin"
  '';

  generatedPath = lib.makeSearchPath "bin" [
    iperf
    ethtool
    iproute2
    socat
    # mn errors out without a telnet binary
    # pkgs.inetutils brings an undesired ifconfig into PATH see #43105
    net-tools
    telnet
  ];

in
stdenv.mkDerivation (finalAttrs: {
  pname = "mininet";
  version = "2.3.1b4";

  src = fetchFromGitHub {
    owner = "mininet";
    repo = "mininet";
    rev = finalAttrs.version;
    hash = "sha256-Z7Vbfu0EJ4+rCpckXrt3hgxeB9N2nnyPIXgPBnpV4uw=";
  };

  outputs = [
    "out"
    "py"
  ];

  nativeBuildInputs = [
    help2man
    makeWrapper
    python3.pkgs.wrapPython
  ];

  propagatedBuildInputs = [
    pyEnv
    which
  ];

  makeFlags = [ "PREFIX=$(out)" ];
  buildFlags = [ "mnexec" ];
  doCheck = false;

  preInstall = ''
    mkdir -p $out $py
    # without --root, install fails
    "${pyEnv.interpreter}" setup.py install \
      --root="/" \
      --prefix="$py" \
      --install-scripts="$out/bin"
  '';

  postFixup = ''
    wrapPythonProgramsIn "$out/bin" "$py ''${pythonPath[*]}"
    wrapProgram "$out/bin/mnexec" \
      --prefix PATH : "${generatedPath}"
    wrapProgram "$out/bin/mn" \
      --prefix PATH : "${generatedPath}"
  '';

  installTargets = [
    "install-mnexec"
    "install-manpages"
  ];

  pythonPath = [ python3.pkgs.setuptools ];

  meta = {
    description = "Emulator for rapid prototyping of Software Defined Networks";
    homepage = "https://github.com/mininet/mininet";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ teto ];
    platforms = lib.platforms.linux;
    mainProgram = "mnexec";
  };
})
