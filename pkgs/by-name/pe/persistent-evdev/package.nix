{
  lib,
  fetchFromGitHub,
  python3Packages,
  udevCheckHook,
}:

python3Packages.buildPythonPackage {
  pname = "persistent-evdev";
  version = "unstable-2022-05-07";

  src = fetchFromGitHub {
    owner = "aiberia";
    repo = "persistent-evdev";
    rev = "52bf246464e09ef4e6f2e1877feccc7b9feba164";
    hash = "sha256-d0i6DL/qgDELet4ew2lyVqzd9TApivRxL3zA3dcsQXY=";
  };

  postPatch = ''
    patchShebangs bin/persistent-evdev.py
  '';

  nativeBuildInputs = [
    udevCheckHook
  ];

  propagatedBuildInputs = with python3Packages; [
    evdev
    pyudev
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp bin/persistent-evdev.py $out/bin

    mkdir -p $out/etc/udev/rules.d
    cp udev/60-persistent-input-uinput.rules $out/etc/udev/rules.d

    runHook postInstall
  '';

  doInstallCheck = true;
  dontBuild = true;
  pyproject = false;

  meta = {
    description = "Persistent virtual input devices for qemu/libvirt/evdev hotplug support";
    homepage = "https://github.com/aiberia/persistent-evdev";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.lodi ];
    platforms = lib.platforms.linux;
    mainProgram = "persistent-evdev.py";
  };
}
