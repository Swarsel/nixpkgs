{
  lib,
  fetchFromGitHub,
  python3,
}:
python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "xorex";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "Neo23x0";
    repo = "xorex";
    rev = finalAttrs.version;
    sha256 = "rBsOSXWnHRhpLmq20XBuGx8gGBM8ouMyOISkbzUcvE4=";
  };

  propagatedBuildInputs = with python3.pkgs; [
    colorama
    pefile
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    chmod +x xorex.py
    mv xorex.py $out/bin/xorex

    runHook postInstall
  '';

  pyproject = false;

  meta = {
    description = "XOR Key Extractor";
    homepage = "https://github.com/Neo23x0/xorex";
    license = lib.licenses.asl20;
    maintainers = [ ];
    mainProgram = "xorex";
  };
})
