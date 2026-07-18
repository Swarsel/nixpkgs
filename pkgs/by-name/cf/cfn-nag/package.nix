{
  lib,
  bundlerEnv,
  bundlerUpdateScript,
  ruby,
}:

bundlerEnv {
  inherit ruby;
  pname = "cfn-nag";
  gemdir = ./.;
  passthru.updateScript = bundlerUpdateScript "cfn-nag";

  meta = {
    description = "Linting tool for CloudFormation templates";
    homepage = "https://github.com/stelligent/cfn_nag";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      mathstlouis
    ];

    platforms = lib.platforms.unix;
    mainProgram = "cfn_nag";
  };
}
