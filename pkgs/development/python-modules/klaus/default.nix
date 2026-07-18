{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  dulwich,
  fetchpatch,
  flask,
  httpauth,
  humanize,
  isPy3k,
  mock,
  pygments,
  pytest,
  python-ctags3,
  requests,
}:

buildPythonPackage rec {
  pname = "klaus";
  version = "3.0.1";

  src = fetchFromGitHub {
    owner = "jonashaag";
    repo = "klaus";
    rev = version;
    hash = "sha256-GflSDhBmMsQ34o3ApraEJ6GmlXXP2kK6WW3lsfr6b7g=";
  };

  # TODO: remove in next version
  patches = [
    (fetchpatch {
      hash = "sha256-gJ/ksm96VRNgqIBp+PX/ljzdfQJYbwTBmZaF2Ctu7Fc=";
      name = "distutils.patch";
      url = "https://github.com/jonashaag/klaus/commit/d50d2aab97fd86c11f3b5a4c1ecbcf1e085f395f.patch";
    })
  ];

  propagatedBuildInputs = [
    flask
    pygments
    dulwich
    httpauth
    humanize
  ];

  # Needs to set up some git repos
  doCheck = false;

  nativeCheckInputs = [
    pytest
    requests
    python-ctags3
  ]
  ++ lib.optional (!isPy3k) mock;

  checkPhase = ''
    ./runtests.sh
  '';

  format = "setuptools";

  prePatch = ''
    substituteInPlace runtests.sh \
      --replace "mkdir -p \$builddir" "mkdir -p \$builddir && pwd"
  '';

  meta = {
    description = "First Git web viewer that Just Works";
    homepage = "https://github.com/jonashaag/klaus";
    license = lib.licenses.isc;
    maintainers = with lib.maintainers; [ pSub ];
    mainProgram = "klaus";
  };
}
