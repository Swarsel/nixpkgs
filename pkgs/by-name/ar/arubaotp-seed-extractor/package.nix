{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonApplication {
  pname = "arubaotp-seed-extractor";
  version = "0-unstable-2022-12-22";

  src = fetchFromGitHub {
    owner = "andry08";
    repo = "ArubaOTP-seed-extractor";
    rev = "534f78bb71594d5806fd2d7a8eade109b0e1d402";
    hash = "sha256-1pv88OClskQOPtJaP7g0duXMe/X3M6Tk+ituZ9UxoIE=";
  };

  nativeBuildInputs = [
    python3Packages.wrapPython
  ];

  installPhase = ''
    libdir="$out/${python3Packages.python.sitePackages}/arubaotp-seed-extractor"
    mkdir -p "$libdir"
    cp scripts/* "$libdir"
    chmod +x "$libdir/main.py"
    wrapPythonProgramsIn "$libdir" "''${pythonPath[*]}"
    mkdir -p $out/bin
    ln -s "$libdir/main.py" $out/bin/arubaotp-seed-extractor
  '';

  pyproject = false;

  pythonPath = with python3Packages; [
    pycryptodome
    pyotp
    qrcode
    requests
  ];

  meta = {
    description = "Extract TOTP seed instead of using ArubaOTP app";
    homepage = "https://github.com/andry08/ArubaOTP-seed-extractor";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fgaz ];
    mainProgram = "arubaotp-seed-extractor";
  };
}
