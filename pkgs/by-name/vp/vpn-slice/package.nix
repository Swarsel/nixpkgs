{
  lib,
  stdenv,
  fetchFromGitHub,
  iproute2,
  iptables,
  nix-update-script,
  python3Packages,
  unixtools,
}:

python3Packages.buildPythonApplication rec {
  pname = "vpn-slice";
  version = "0.16.1";

  src = fetchFromGitHub {
    owner = "dlenski";
    repo = "vpn-slice";
    rev = "v${version}";
    sha256 = "sha256-T6VULLNRLWO4OcAsuTmhty6H4EhinyxQSg0dfv2DUJs=";
  };

  postPatch =
    lib.optionalString stdenv.hostPlatform.isDarwin ''
      substituteInPlace vpn_slice/mac.py \
        --replace-fail "'/sbin/route'" "'${unixtools.route}/bin/route'"
    ''
    + lib.optionalString stdenv.hostPlatform.isLinux ''
      substituteInPlace vpn_slice/linux.py \
        --replace-fail "'/sbin/ip'" "'${iproute2}/bin/ip'" \
        --replace-fail "'/sbin/iptables'" "'${iptables}/bin/iptables'"
    '';

  doCheck = false;

  build-system = with python3Packages; [
    setuptools
  ];

  dependencies = with python3Packages; [
    setuptools # can be removed with next package update, upstream no longer has a dependency on distutils
    setproctitle
    dnspython
  ];

  pyproject = true;

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "vpnc-script replacement for easy and secure split-tunnel VPN setup";
    homepage = "https://github.com/dlenski/vpn-slice";
    license = lib.licenses.gpl3;
    maintainers = [ ];
    mainProgram = "vpn-slice";
  };
}
