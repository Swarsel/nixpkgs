{
  lib,
  stdenv,
  fetchFromGitHub,
  bintools-unwrapped,
  coreutils,
  file,
  gdb,
  git,
  makeWrapper,
  ps,
  python3,
}:

let
  pythonPath =
    with python3.pkgs;
    makePythonPath [
      keystone-engine
      unicorn
      capstone
      ropper
    ];

in
stdenv.mkDerivation (finalAttrs: {
  pname = "gef";
  version = "2026.01";

  src = fetchFromGitHub {
    owner = "hugsy";
    repo = "gef";
    rev = finalAttrs.version;
    sha256 = "sha256-KHPX4mGo+yy56Rmjd5yx8U5doXrACV2/ZCh+NeQxB0Y=";
  };

  nativeBuildInputs = [ makeWrapper ];

  nativeCheckInputs = [
    gdb
    file
    ps
    git
    python3
    python3.pkgs.pytest
    python3.pkgs.pytest-xdist
    python3.pkgs.keystone-engine
    python3.pkgs.unicorn
    python3.pkgs.capstone
    python3.pkgs.ropper
  ];

  checkPhase = ''
    # Skip some tests that require network access.
    sed -i '/def test_cmd_shellcode_get(self):/i \ \ \ \ @unittest.skip(reason="not available in sandbox")' tests/runtests.py
    sed -i '/def test_cmd_shellcode_search(self):/i \ \ \ \ @unittest.skip(reason="not available in sandbox")' tests/runtests.py

    # Patch the path to /bin/ls.
    sed -i 's+/bin/ls+${coreutils}/bin/ls+g' tests/runtests.py

    # Run the tests.
    make test
  '';

  installPhase = ''
    mkdir -p $out/share/gef
    cp gef.py $out/share/gef
    makeWrapper ${gdb}/bin/gdb $out/bin/gef \
      --add-flags "-q -x $out/share/gef/gef.py" \
      --set NIX_PYTHONPATH ${pythonPath} \
      --prefix PATH : ${
        lib.makeBinPath [
          python3
          bintools-unwrapped # for readelf
          file
          ps
        ]
      }
  '';

  dontBuild = true;

  meta = {
    description = "Modern experience for GDB with advanced debugging features for exploit developers & reverse engineers";
    homepage = "https://github.com/hugsy/gef";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ freax13 ];
    platforms = lib.platforms.all;
    mainProgram = "gef";
  };
})
