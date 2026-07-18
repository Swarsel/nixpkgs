{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hatchling,
  pytestCheckHook,
  termcolor,
}:

buildPythonPackage rec {
  pname = "sparklines";
  version = "0.7.0";

  src = fetchFromGitHub {
    owner = "deeplook";
    repo = "sparklines";
    tag = "v${version}";
    sha256 = "sha256-jiMrxZMWN+moap0bDH+uy66gF4XdGst9HJpnboJrQm4=";
  };

  postPatch = ''
    export TMPDIR=$PWD/tmp
    mkdir -p $TMPDIR
    substituteInPlace tests/test_sparkline.py \
      --replace-fail "/tmp/" "$TMPDIR/"
  '';

  propagatedBuildInputs = [
    hatchling
    termcolor
  ];

  nativeCheckInputs = [ pytestCheckHook ];
  pyproject = true;
  pythonImportsCheck = [ "sparklines" ];

  meta = {
    description = "This Python package implements Edward Tufte's concept of sparklines, but limited to text only";
    homepage = "https://github.com/deeplook/sparklines";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      rhoriguchi
    ];

    mainProgram = "sparklines";
  };
}
