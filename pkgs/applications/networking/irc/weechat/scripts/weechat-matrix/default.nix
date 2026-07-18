{
  lib,
  fetchFromGitHub,
  aiohttp,
  atomicwrites,
  attrs,
  buildPythonPackage,
  fetchpatch,
  future,
  logbook,
  matrix-nio,
  pygments,
  pyopenssl,
  python,
  requests,
  webcolors,
}:

let
  scriptPython = python.withPackages (
    ps: with ps; [
      aiohttp
      requests
      python-magic
    ]
  );

  version = "0.3.0";
in
buildPythonPackage {
  inherit version;
  pname = "weechat-matrix";

  src = fetchFromGitHub {
    owner = "poljar";
    repo = "weechat-matrix";
    rev = version;
    hash = "sha256-o4kgneszVLENG167nWnk2FxM+PsMzi+PSyMUMIktZcc=";
  };

  patches = [
    # server: remove set_npn_protocols()
    (fetchpatch {
      hash = "sha256-Grdht+TOFvCYRpL7uhPivqL7YzLoNVF3iQNHgbv1Te0=";
      url = "https://patch-diff.githubusercontent.com/raw/poljar/weechat-matrix/pull/309.patch";
    })
    # Fix compatibility with matrix-nio 0.21
    (fetchpatch {
      hash = "sha256-MAfxJ85dqz5PNwp/GJdHA2VvXVdWh+Ayx5g0oHiw9rs=";
      includes = [ "matrix/config.py" ];
      url = "https://github.com/poljar/weechat-matrix/commit/feae9fda26ea9de98da9cd6733980a203115537e.patch";
    })
  ];

  propagatedBuildInputs = [
    pyopenssl
    webcolors
    future
    atomicwrites
    attrs
    logbook
    pygments
    (matrix-nio.override { withOlm = true; })
    aiohttp
    requests
  ];

  doCheck = false;

  installPhase = ''
    mkdir -p $out/share $out/bin
    cp main.py $out/share/matrix.py

    cp contrib/matrix_upload.py $out/bin/matrix_upload
    cp contrib/matrix_decrypt.py $out/bin/matrix_decrypt
    cp contrib/matrix_sso_helper.py $out/bin/matrix_sso_helper
    substituteInPlace $out/bin/matrix_upload \
      --replace-fail '/usr/bin/env -S python3' '${scriptPython}/bin/python'
    substituteInPlace $out/bin/matrix_sso_helper \
      --replace-fail '/usr/bin/env -S python3' '${scriptPython}/bin/python'
    substituteInPlace $out/bin/matrix_decrypt \
      --replace-fail '/usr/bin/env python3' '${scriptPython}/bin/python'

    mkdir -p $out/${python.sitePackages}
    cp -r matrix $out/${python.sitePackages}/matrix
  '';

  postFixup = ''
    addToSearchPath program_PYTHONPATH $out/${python.sitePackages}
    patchPythonScript $out/share/matrix.py
    substituteInPlace $out/${python.sitePackages}/matrix/server.py --replace-fail \"matrix_sso_helper\" \"$out/bin/matrix_sso_helper\"
    substituteInPlace $out/${python.sitePackages}/matrix/uploads.py --replace-fail \"matrix_upload\" \"$out/bin/matrix_upload\"
  '';

  dontBuild = true;
  dontPatchShebangs = true;
  pyproject = false;
  passthru.scripts = [ "matrix.py" ];

  meta = {
    description = "Python plugin for Weechat that lets Weechat communicate over the Matrix protocol";
    homepage = "https://github.com/poljar/weechat-matrix";
    license = lib.licenses.isc;
    maintainers = with lib.maintainers; [ tilpner ];
    platforms = lib.platforms.unix;
  };
}
