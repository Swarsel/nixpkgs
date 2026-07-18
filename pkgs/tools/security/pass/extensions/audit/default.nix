{
  lib,
  stdenv,
  fetchFromGitHub,
  gnupg,
  pass,
  python3,
}:

python3.pkgs.buildPythonApplication rec {
  pname = "pass-audit";
  version = "1.2";

  src = fetchFromGitHub {
    owner = "roddhjav";
    repo = "pass-audit";
    rev = "v${version}";
    hash = "sha256-xigP8LxRXITLF3X21zhWx6ooFNSTKGv46yFSt1dd4vs=";
  };

  outputs = [
    "out"
    "man"
  ];

  patches = [
    ./0001-Set-base-to-an-empty-value.patch
    ./0002-Fix-audit.bash-setup.patch
  ];

  postPatch = ''
    substituteInPlace audit.bash \
      --replace-fail python3 "${lib.getExe python3}"
    rm Makefile
    patchShebangs audit.bash
  '';

  # Tests freeze on darwin with: pass-audit-1.1 (checkPhase): EOFError
  doCheck = !stdenv.hostPlatform.isDarwin;

  nativeCheckInputs = [
    python3.pkgs.green
    pass
    gnupg
  ];

  checkPhase = ''
    python3 -m green -q
  '';

  postInstall = ''
    mkdir -p $out/lib/password-store/extensions
    install -m777 audit.bash $out/lib/password-store/extensions/audit.bash
    cp -r share $out/
    buildPythonPath "$out $dependencies"
    wrapProgram $out/lib/password-store/extensions/audit.bash \
      --prefix PYTHONPATH : "$PYTHONPATH" \
      --run "export COMMAND"
  '';

  build-system = with python3.pkgs; [ setuptools ];

  dependencies = with python3.pkgs; [
    requests
    setuptools
    zxcvbn
  ];

  pyproject = true;
  pythonImportsCheck = [ "pass_audit" ];

  meta = {
    description = "Pass extension for auditing your password repository";
    homepage = "https://github.com/roddhjav/pass-audit";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ ma27 ];
    platforms = lib.platforms.unix;
  };
}
