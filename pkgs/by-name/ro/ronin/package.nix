{
  lib,
  bundlerEnv,
  bundlerUpdateScript,
  defaultGemConfig,
  ronin,
  testers,
  yasm,
}:

bundlerEnv rec {
  pname = "ronin";
  version = "2.1.1";

  postBuild = ''
    shopt -s extglob
    rm -f $out/bin/!(ronin*)
  '';

  gemConfig = defaultGemConfig // {
    ronin-code-asm = attrs: {
      postPatch = ''
        substituteInPlace lib/ronin/code/asm/program.rb \
          --replace "YASM::Command.run(" "YASM::Command.run(
          command_path: '${yasm}/bin/yasm',"
      '';

      dontBuild = false;
    };
  };

  gemdir = ./.;

  passthru.tests.version = testers.testVersion {
    version = "ronin ${version}";
    command = "ronin --version";
    package = ronin;
  };

  passthru.updateScript = bundlerUpdateScript "ronin";

  meta = {
    description = "Free and Open Source Ruby toolkit for security research and development";
    homepage = "https://ronin-rb.dev";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ Ch1keen ];
  };
}
