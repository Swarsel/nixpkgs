{
  lib,
  fetchPypi,
  gdb,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "gdbgui";
  version = "0.15.3.0";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-/HyFE0JnoN03CDyCQCo/Y9RyH4YOMoeB7khReIb8t7Y=";
  };

  postPatch = ''
    echo ${finalAttrs.version} > gdbgui/VERSION.txt
    # relax version requirements
    sed -i 's/==.*$//' requirements.txt
  '';

  buildInputs = [ gdb ];
  # tests do not work without stdout/stdin
  doCheck = false;

  postInstall = ''
    wrapProgram $out/bin/gdbgui \
      --prefix PATH : ${lib.makeBinPath [ gdb ]}
  '';

  __structuredAttrs = true;
  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [
    eventlet
    flask-compress
    flask-socketio
    pygdbmi
    pygments
  ];

  pyproject = true;

  meta = {
    description = "Browser-based frontend for GDB";
    homepage = "https://www.gdbgui.com/";
    license = lib.licenses.gpl3;

    maintainers = with lib.maintainers; [
      yrashk
      dump_stack
    ];

    platforms = lib.platforms.unix;
    mainProgram = "gdbgui";
  };
})
