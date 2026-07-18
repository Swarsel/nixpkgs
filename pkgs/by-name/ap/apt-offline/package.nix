{
  lib,
  fetchFromGitHub,
  gnupg,
  installShellFiles,
  python3Packages,
}:

let
  pname = "apt-offline";
  version = "1.8.6";

  src = fetchFromGitHub {
    owner = "rickysarraf";
    repo = "apt-offline";
    tag = "v${version}";
    hash = "sha256-PnU8vbEY+EpEv8D6Ap/iJqfwOWxpNytT+XDFCFD8XqU=";
  };
in
python3Packages.buildPythonApplication {
  inherit pname version src;

  outputs = [
    "out"
    "man"
  ];

  postPatch = ''
    substituteInPlace org.debian.apt.aptoffline.policy \
      --replace-fail /usr/bin/ "$out/bin"

    substituteInPlace apt_offline_core/AptOfflineCoreLib.py \
      --replace-fail /usr/bin/gpgv "${lib.getBin gnupg}/bin/gpgv"
  '';

  nativeBuildInputs = [ installShellFiles ];
  doCheck = false; # API incompatibilities, maybe?

  postInstall = ''
    installManPage apt-offline.8
  '';

  postFixup = ''
    rm "$out/bin/apt-offline-gui" "$out/bin/apt-offline-gui-pkexec"
  '';

  build-system = with python3Packages; [
    setuptools
  ];

  pyproject = true;
  pythonImportsCheck = [ "apt_offline_core" ];

  meta = {
    description = "Offline APT package manager";
    homepage = "https://github.com/rickysarraf/apt-offline";
    license = with lib.licenses; [ gpl3Plus ];
    maintainers = [ ];
    mainProgram = "apt-offline";
  };
}
# TODO: verify GUI and pkexec
