{
  lib,
  fetchFromGitHub,
  buildGoModule,
  makeBinaryWrapper,
  symlinkJoin,
  vale,
  valeStyles,
  versionCheckHook,
}:

buildGoModule rec {
  pname = "vale";
  version = "3.15.1";

  src = fetchFromGitHub {
    owner = "errata-ai";
    repo = "vale";
    tag = "v${version}";
    hash = "sha256-zp3yEFtYOMsPh6WqIzDnBSvO4mPAcysPkGSnsM44Z9U=";
  };

  vendorHash = "sha256-OOatkx5c+0VCT1+M/Ra60Ujy/djgQd1f3SIYoh9Mesg=";
  # Tests require network access
  doCheck = false;
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  ldflags = [
    "-s"
    "-X main.version=${version}"
  ];

  subPackages = [ "cmd/vale" ];

  passthru.withStyles =
    selector:
    symlinkJoin {
      nativeBuildInputs = [ makeBinaryWrapper ];

      postBuild = ''
        wrapProgram "$out/bin/vale" \
          --set VALE_STYLES_PATH "$out/share/vale/styles/"
      '';

      name = "vale-with-styles-${vale.version}";
      paths = [ vale ] ++ selector valeStyles;

      meta = {
        inherit (vale.meta) mainProgram;
      };
    };

  meta = {
    description = "Syntax-aware linter for prose built with speed and extensibility in mind";

    longDescription = ''
      Vale in Nixpkgs offers the helper `.withStyles` allow you to install it
      predefined styles:

      ```nix
      vale.withStyles (s: [ s.alex s.google ])
      ```
    '';

    homepage = "https://vale.sh/";
    changelog = "https://github.com/errata-ai/vale/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ pbsds ];
    mainProgram = "vale";
  };
}
