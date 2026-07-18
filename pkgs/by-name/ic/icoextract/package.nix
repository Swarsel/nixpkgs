{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "icoextract";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "jlu5";
    repo = "icoextract";
    rev = finalAttrs.version;
    hash = "sha256-uesnYwv1ig7cnakWpH7MKeN6cfjasxVYLHs1JYG0Tss=";
  };

  # tests expect mingw and multiarch
  doCheck = false;

  postInstall = ''
    install -Dm644 exe-thumbnailer.thumbnailer -t $out/share/thumbnailers

    substituteInPlace $out/share/thumbnailers/exe-thumbnailer.thumbnailer \
      --replace-fail "Exec=exe-thumbnailer" "Exec=$out/bin/exe-thumbnailer"
  '';

  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [
    pefile
    pillow
  ];

  pyproject = true;
  pythonImportsCheck = [ "icoextract" ];

  meta = {
    description = "Extract icons from Windows PE files";
    homepage = "https://github.com/jlu5/icoextract";
    changelog = "https://github.com/jlu5/icoextract/blob/${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      donovanglover
    ];

    mainProgram = "icoextract";
  };
})
