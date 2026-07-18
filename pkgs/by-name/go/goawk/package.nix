{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  gawk,
}:

buildGoModule (finalAttrs: {
  pname = "goawk";
  version = "1.31.0";

  src = fetchFromGitHub {
    owner = "benhoyt";
    repo = "goawk";
    rev = "v${finalAttrs.version}";
    hash = "sha256-Luz6boPGIJqF/PJHZmnu3zChT5g8Wt37eOMtFS7j2pI=";
  };

  postPatch = ''
    substituteInPlace goawk_test.go \
      --replace "TestCommandLine" "SkipCommandLine" \
      --replace "TestDevStdout" "SkipDevStdout" \
      --replace "TestFILENAME" "SkipFILENAME" \
      --replace "TestWildcards" "SkipWildcards"

    substituteInPlace interp/interp_test.go \
      --replace "TestShellCommand" "SkipShellCommand"
  '';

  vendorHash = null;
  doCheck = (stdenv.system != "aarch64-darwin");
  nativeCheckInputs = [ gawk ];

  checkFlags = [
    "-awk"
    "${gawk}/bin/gawk"
  ];

  meta = {
    description = "POSIX-compliant AWK interpreter written in Go";
    homepage = "https://benhoyt.com/writings/goawk/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ abbe ];
    mainProgram = "goawk";
  };
})
