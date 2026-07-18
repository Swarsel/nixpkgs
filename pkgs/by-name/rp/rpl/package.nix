{
  lib,
  fetchPypi,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "rpl";
  version = "1.18.1";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-Fr0BMv+QMhVaHMg+Xd7pPe4/swH0dBADABKgbSIjUCo=";
  };

  nativeBuildInputs = [
    python3Packages.setuptools
  ];

  propagatedBuildInputs = [
    python3Packages.argparse-manpage
    python3Packages.chainstream
    python3Packages.chardet
    python3Packages.regex
  ];

  nativeCheckInputs = [
    python3Packages.pytest-datafiles
    python3Packages.pytestCheckHook
  ];

  pyproject = true;

  meta = {
    description = "Replace strings in files";
    homepage = "https://github.com/rrthomas/rpl";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ cbley ];
    mainProgram = "rpl";
  };
})
