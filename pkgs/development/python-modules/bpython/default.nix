{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  curtsies,
  cwcwidth,
  fetchpatch,
  gitUpdater,
  greenlet,
  jedi,
  pygments,
  pyperclip,
  pytestCheckHook,
  pyxdg,
  requests,
  setuptools,
  urwid,
  watchdog,
}:

buildPythonPackage rec {
  pname = "bpython";
  version = "0.26";

  src = fetchFromGitHub {
    owner = "bpython";
    repo = "bpython";
    tag = "${version}-release";
    hash = "sha256-NmWM0fdzS9n5FSnNJOCdS1JE5ZHrmJXqCuHa54rT8GU=";
  };

  patches = [
    # This should be removed in the next release.
    (fetchpatch {
      hash = "sha256-z55EkLT51ulz/V3XgjP1cbQza9ztb5YHu1UlXlbaWTQ=";
      url = "https://github.com/bpython/bpython/commit/870e81cb5a6860f1ba15744c81b97f71467eedf9.patch";
    })
  ];

  postPatch = ''
    substituteInPlace setup.py \
      --replace-fail 'version = "unknown"' 'version = "${version}"'
  '';

  nativeCheckInputs = [
    pytestCheckHook
  ]
  ++ lib.concatAttrValues optional-dependencies;

  postInstall = ''
    substituteInPlace "$out/share/applications/org.bpython-interpreter.bpython.desktop" \
      --replace "Exec=/usr/bin/bpython" "Exec=bpython"
  '';

  build-system = [ setuptools ];

  dependencies = [
    curtsies
    cwcwidth
    greenlet
    pygments
    pyxdg
    requests
  ];

  optional-dependencies = {
    clipboard = [ pyperclip ];
    jedi = [ jedi ];
    urwid = [ urwid ];
    watch = [ watchdog ];
  };

  pyproject = true;
  pythonImportsCheck = [ "bpython" ];

  passthru.updateScript = gitUpdater {
    rev-suffix = "-release";
  };

  meta = {
    description = "Fancy curses interface to the Python interactive interpreter";
    homepage = "https://bpython-interpreter.org/";
    changelog = "https://github.com/bpython/bpython/blob/${src.tag}/CHANGELOG.rst";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      flokli
      dotlambda
    ];
  };
}
