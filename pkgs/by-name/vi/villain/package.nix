{
  lib,
  fetchFromGitHub,
  makeWrapper,
  python3,
  python3Packages,
}:

python3Packages.buildPythonApplication rec {
  pname = "villain";
  version = "2.2.1";

  src = fetchFromGitHub {
    owner = "t3l3machus";
    repo = "Villain";
    tag = "V${version}";
    hash = "sha256-eIPxidBBVmjt/E1F8G3zPwteB1qsk3a5LD69CiNVApY=";
  };

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/{bin,share/villain}
    rm README.md requirements.txt LICENSE.md
    cp -a * $out/share/villain/
    makeWrapper ${python3}/bin/python $out/bin/villain \
      --add-flags "$out/share/villain/Villain.py" \
      --prefix PYTHONPATH : ${python3Packages.makePythonPath dependencies}
    runHook postInstall
  '';

  dependencies = with python3Packages; [
    gnureadline
    netifaces
    pycryptodomex
    pyperclip
    requests
  ];

  pyproject = false;

  meta = {
    description = "High level stage 0/1 C2 framework that can handle multiple TCP socket & HoaxShell-based reverse shells";
    homepage = "https://github.com/t3l3machus/Villain";
    license = lib.licenses.cc-by-nc-nd-40;
    maintainers = [ ];
    platforms = lib.platforms.unix;
    mainProgram = "villain";
  };
}
