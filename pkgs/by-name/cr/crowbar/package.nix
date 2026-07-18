{
  lib,
  fetchFromGitHub,
  freerdp,
  nmap,
  openvpn,
  python3Packages,
  tigervnc,
}:

python3Packages.buildPythonApplication {
  pname = "crowbar";
  version = "unstable-2020-04-23";

  src = fetchFromGitHub {
    owner = "galkan";
    repo = "crowbar";
    rev = "500d633ff5ddfcbc70eb6d0b4d2181e5b8d3c535";
    sha256 = "05m9vywr9976pc7il0ak8nl26mklzxlcqx0p8rlfyx1q766myqzf";
  };

  # Sanity check
  checkPhase = ''
    $out/bin/crowbar --help > /dev/null
  '';

  build-system = [ python3Packages.setuptools ];
  dependencies = [ python3Packages.paramiko ];

  patchPhase = ''
    sed -i 's,/usr/bin/xfreerdp,${freerdp}/bin/xfreerdp,g' lib/main.py
    sed -i 's,/usr/bin/vncviewer,${tigervnc}/bin/vncviewer,g' lib/main.py
    sed -i 's,/usr/sbin/openvpn,${openvpn}/bin/openvpn,g' lib/main.py

    sed -i 's,/usr/bin/nmap,${nmap}/bin/nmap,g' lib/nmap.py
  '';

  pyproject = true;

  meta = {
    description = "Brute forcing tool that can be used during penetration tests";
    homepage = "https://github.com/galkan/crowbar";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ pamplemousse ];
    mainProgram = "crowbar";
  };
}
