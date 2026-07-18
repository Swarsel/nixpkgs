{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  gitMinimal,
  gnupg,
  installShellFiles,
  makeBinaryWrapper,
  nix-update-script,
  versionCheckHook,
  wl-clipboard,
  xclip,
  passAlias ? false,
}:

let
  wrapperPath = lib.makeBinPath (
    [
      gitMinimal
      gnupg
      xclip
    ]
    ++ lib.optionals stdenv.hostPlatform.isLinux [
      wl-clipboard
    ]
  );
in
buildGoModule (finalAttrs: {
  pname = "gopass";
  version = "1.16.1";

  src = fetchFromGitHub {
    owner = "gopasspw";
    repo = "gopass";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Yr66+LUEoONNkSQUQhIWtLvxN0a5YtRVbn/nJRLqn+E=";
  };

  nativeBuildInputs = [
    installShellFiles
    makeBinaryWrapper
  ];

  vendorHash = "sha256-ebnnnAD7SQJrSVOPborHUWd8ThOstIgihEIUjrnCztQ=";

  postInstall = ''
    installManPage gopass.1
    installShellCompletion --cmd gopass \
      --zsh zsh.completion \
      --bash bash.completion \
      --fish fish.completion
  ''
  + lib.optionalString passAlias ''
    ln -s $out/bin/gopass $out/bin/pass
  '';

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
    gitMinimal
  ];

  postFixup = ''
    wrapProgram $out/bin/gopass \
      --prefix PATH : "${wrapperPath}" \
      --set GOPASS_NO_REMINDER true
  '';

  ldflags = [
    "-s"
    "-w"
    "-X main.version=${finalAttrs.version}"
    "-X main.commit=${finalAttrs.src.rev}"
  ];

  subPackages = [ "." ];

  passthru = {
    inherit wrapperPath;
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Slightly more awesome Standard Unix Password Manager for Teams. Written in Go";

    longDescription = ''
      gopass is a rewrite of the pass password manager in Go with the aim of
      making it cross-platform and adding additional features. Our target
      audience are professional developers and sysadmins (and especially teams
      of those) who are well versed with a command line interface. One explicit
      goal for this project is to make it more approachable to non-technical
      users. We go by the UNIX philosophy and try to do one thing and do it
      well, providing a stellar user experience and a sane, simple interface.
    '';

    homepage = "https://www.gopass.pw/";
    changelog = "https://github.com/gopasspw/gopass/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      rvolosatovs
      sikmir
      yzx9
    ];

    mainProgram = "gopass";
  };
})
