{
  lib,
  stdenv,
  fetchFromGitHub,
  gobject-introspection,
  pciutils,
  python3Packages,
  wrapGAppsNoGuiHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "throttled";
  version = "0.11";

  src = fetchFromGitHub {
    owner = "erpalma";
    repo = "throttled";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-+3ktDkr5hvOfHcch4+mjgJqcuw24UgWTkJqTyDQumyk=";
  };

  # The upstream unit both assumes the install location, and tries to run in a virtualenv
  postPatch = ''
    sed -e 's|ExecStart=.*|ExecStart=${placeholder "out"}/bin/throttled.py|' -i systemd/throttled.service

    substituteInPlace throttled.py --replace "'setpci'" "'${pciutils}/bin/setpci'"
  '';

  nativeBuildInputs = [
    gobject-introspection
    python3Packages.wrapPython
    wrapGAppsNoGuiHook
  ];

  installPhase = ''
    runHook preInstall
    install -D -m755 -t $out/bin throttled.py
    install -D -t $out/bin throttled.py mmio.py
    install -D -m644 -t $out/etc etc/*
    install -D -m644 -t $out/lib/systemd/system systemd/*
    runHook postInstall
  '';

  preFixup = ''
    makeWrapperArgs+=("''${gappsWrapperArgs[@]}")
  '';

  postFixup = "wrapPythonPrograms";
  dontWrapGApps = true;

  pythonPath = with python3Packages; [
    configparser
    dbus-python
    pygobject3
  ];

  meta = {
    description = "Fix for Intel CPU throttling issues";
    homepage = "https://github.com/erpalma/throttled";
    license = lib.licenses.mit;
    maintainers = [ ];
    platforms = [ "x86_64-linux" ];
  };
})
