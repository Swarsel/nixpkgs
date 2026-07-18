{
  lib,
  azure-cli,
  azure-cli-extensions,
  bitbucket-cli,
  callPackage,
  claude-code,
  code-cursor,
  codex,
  cursor-cli,
  gh,
  git,
  glab,
  jujutsu,
  makeBinaryWrapper,
  opencode,
  symlinkJoin,
  enableAzureDevOps ? false,
  enableBitbucket ? false,
  enableClaude ? false,
  enableCodex ? true,
  enableCursor ? false,
  enableCursorCli ? false,
  enableGit ? true,
  enableGitHub ? true,
  enableGitLab ? false,
  enableJujutsu ? false,
  enableOpencode ? false,
  t3code-unwrapped ? callPackage ./unwrapped.nix { },
}:

let
  runtimePackages =
    lib.optionals enableAzureDevOps [
      (azure-cli.withExtensions [ azure-cli-extensions.azure-devops ])
    ]
    ++ lib.optionals enableBitbucket [ bitbucket-cli ]
    ++ lib.optionals enableClaude [ claude-code ]
    ++ lib.optionals enableCodex [ codex ]
    ++ lib.optionals enableCursor [ code-cursor ]
    ++ lib.optionals enableCursorCli [ cursor-cli ]
    ++ lib.optionals enableGitHub [ gh ]
    ++ lib.optionals enableGit [ git ]
    ++ lib.optionals enableGitLab [ glab ]
    ++ lib.optionals enableJujutsu [ jujutsu ]
    ++ lib.optionals enableOpencode [ opencode ];

in
symlinkJoin {
  inherit (t3code-unwrapped) version;
  pname = "t3code";
  strictDeps = true;
  nativeBuildInputs = [ makeBinaryWrapper ];

  postBuild = lib.optionalString (runtimePackages != [ ]) ''
    for program in "$out/bin"/*; do
      wrapProgram "$program" \
        --prefix PATH : "${lib.makeBinPath runtimePackages}"
    done
  '';

  __structuredAttrs = true;
  paths = [ t3code-unwrapped ];

  passthru = {
    unwrapped = t3code-unwrapped;
  }
  // t3code-unwrapped.passthru;

  meta = {
    # Manually inherit so that pos works
    inherit (t3code-unwrapped.meta)
      description
      homepage
      downloadPage
      changelog
      license
      maintainers
      mainProgram
      platforms
      ;
  };
}
