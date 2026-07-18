{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  installShellFiles,
  makeWrapper,
  nix-update-script,
  pandoc,
  versionCheckHook,
}:

buildGoModule (finalAttrs: {
  pname = "ov";
  version = "0.54.0";

  src = fetchFromGitHub {
    owner = "noborus";
    repo = "ov";
    tag = "v${finalAttrs.version}";
    hash = "sha256-cIjtu4T9It+u/ZVC+XoUacvnYw51QSnbTNge1QaHr0s=";
  };

  outputs = [
    "out"
    "doc"
  ];

  nativeBuildInputs = [
    installShellFiles
    pandoc
    makeWrapper
  ];

  vendorHash = "sha256-eQh/S2isNvT9l+A4uK+/APcw+krsFL54OD5E6yEduxU=";

  postInstall =
    lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
      installShellCompletion --cmd ov \
        --bash <($out/bin/ov --completion bash) \
        --fish <($out/bin/ov --completion fish) \
        --zsh <($out/bin/ov --completion zsh)
    ''
    + ''
      mkdir -p $out/share/$name
      cp $src/ov-less.yaml $out/share/$name/less-config.yaml
      makeWrapper $out/bin/ov $out/bin/ov-less --add-flags "--config $out/share/$name/less-config.yaml"

      mkdir -p $doc/share/doc/$name
      pandoc -s < $src/README.md > $doc/share/doc/$name/README.html
      mkdir -p $doc/share/$name
      cp $src/ov.yaml $doc/share/$name/sample-config.yaml
    '';

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  __structuredAttrs = true;

  ldflags = [
    "-s"
    "-X=main.Version=v${finalAttrs.version}"
    "-X=main.Revision=${finalAttrs.src.rev}"
  ];

  subPackages = [ "." ];

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Feature-rich terminal-based text viewer";
    homepage = "https://noborus.github.io/ov";
    changelog = "https://github.com/noborus/ov/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ Holiu618 ];
    mainProgram = "ov";
  };
})
