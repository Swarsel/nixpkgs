{
  lib,
  stdenv,
  fetchFromGitHub,
  python3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "vcs_query";
  version = "0.4.0";

  src = fetchFromGitHub {
    owner = "mageta";
    repo = "vcs_query";
    rev = "v${finalAttrs.version}";
    sha256 = "05va0na9yxkpqhm9v0x3k58148qcf2bbcv5bnmj7vn9r7fwyjrlx";
  };

  nativeBuildInputs = [
    python3
    python3.pkgs.wrapPython
  ];

  installPhase = ''
    install -Dm0755 vcs_query.py $out/bin/vcs_query
    patchShebangs $out/bin
    buildPythonPath ${python3.pkgs.vobject};
    patchPythonScript $out/bin/vcs_query
  '';

  dontBuild = true;

  meta = {
    description = "Email query-command to use vCards in mutt and Vim";
    homepage = "https://github.com/mageta/vcs_query";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ma27 ];
    mainProgram = "vcs_query";
  };
})
