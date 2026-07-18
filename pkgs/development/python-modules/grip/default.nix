{
  lib,
  fetchFromGitHub,
  # Python bits:
  buildPythonPackage,
  docopt,
  fetchpatch,
  flask,
  markdown,
  path-and-address,
  pygments,
  pytest,
  requests,
  responses,
  tabulate,
}:

buildPythonPackage rec {
  pname = "grip";
  version = "4.6.1";

  src = fetchFromGitHub {
    owner = "joeyespo";
    repo = "grip";
    rev = "v${version}";
    hash = "sha256-CHL2dy0H/i0pLo653F7aUHFvZHTeZA6jC/rwn1KrEW4=";
  };

  patches = [
    # https://github.com/NixOS/nixpkgs/issues/288478
    (fetchpatch {
      hash = "sha256-veVJKJtt8mP1jmseRD7pNR3JgIxX1alYHyQok/rBpiQ=";
      name = "set-default-encoding.patch";
      url = "https://github.com/joeyespo/grip/commit/2784eb2c1515f1cdb1554d049d48b3bff0f42085.patch";
    })
  ];

  propagatedBuildInputs = [
    docopt
    flask
    markdown
    path-and-address
    pygments
    requests
    tabulate
  ];

  nativeCheckInputs = [
    pytest
    responses
  ];

  checkPhase = ''
    export PATH="$PATH:$out/bin"
    py.test -xm "not assumption"
  '';

  format = "setuptools";

  meta = {
    description = "Preview GitHub Markdown files like Readme locally before committing them";
    homepage = "https://github.com/joeyespo/grip";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ koral ];
    mainProgram = "grip";
  };
}
