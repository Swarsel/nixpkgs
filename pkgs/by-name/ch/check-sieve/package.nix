{
  lib,
  stdenv,
  fetchFromGitHub,
  bison,
  diffutils,
  flex,
  nix-update-script,
  python3,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "check-sieve";
  version = "1.0.1";

  src = fetchFromGitHub {
    owner = "dburkart";
    repo = "check-sieve";
    tag = "v${finalAttrs.version}";
    hash = "sha256-kNHRid87RW+tm3nmMEe8Y5dcgLZMHICzY2rgWlK3h0M=";
  };

  nativeBuildInputs = [
    bison
    flex
  ];

  env.NIX_CFLAGS_COMPILE = "-Wno-error=unused-result";
  doCheck = true;

  nativeCheckInputs = [
    (python3.withPackages (p: [ p.setuptools ]))
  ];

  preCheck = ''
    substituteInPlace test/{AST,simulate}/util.py \
      --replace-fail "/usr/bin/diff" "${diffutils}/bin/diff"
  '';

  installPhase = ''
    runHook preInstall
    install -Dm755 check-sieve -t $out/bin
    runHook postInstall
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [ "--version-regex=v(.*)" ];
  };

  meta = {
    description = "Syntax checker for mail sieves";
    homepage = "https://github.com/dburkart/check-sieve";
    changelog = "https://github.com/dburkart/check-sieve/blob/${finalAttrs.src.tag}/ChangeLog";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ eilvelia ];
    platforms = lib.platforms.unix;
    mainProgram = "check-sieve";
  };
})
