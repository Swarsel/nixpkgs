{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  django,
  drafthorse,
  ghostscript_headless,
  pretix-plugin-build,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pretix-zugferd";
  version = "2.6.3";

  src = fetchFromGitHub {
    owner = "pretix";
    repo = "pretix-zugferd";
    rev = "v${version}";
    hash = "sha256-HE3L5VS0n1NL/jprcnMwaNriFKIN1pogPM2cDw2ZPdk=";
  };

  postPatch = ''
    substituteInPlace pretix_zugferd/invoice.py \
      --replace-fail 'fallback="gs"' 'fallback="${lib.getExe ghostscript_headless}"'
  '';

  postBuild = ''
    make
  '';

  doCheck = false; # no tests

  build-system = [
    django
    pretix-plugin-build
    setuptools
  ];

  dependencies = [ drafthorse ];
  pyproject = true;
  pythonImportsCheck = [ "pretix_zugferd" ];
  pythonRelaxDeps = [ "drafthorse" ];

  meta = {
    description = "Annotate pretix' invoices with ZUGFeRD data";
    homepage = "https://github.com/pretix/pretix-zugferd";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ hexa ];
  };
}
