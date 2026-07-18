{
  lib,
  fetchFromGitHub,
  bash,
  buildGoModule,
  hyprland,
  makeWrapper,
  nix-update-script,
  versionCheckHook,
}:

buildGoModule (finalAttrs: {
  pname = "hyprmoncfg";
  version = "1.8.0";

  src = fetchFromGitHub {
    owner = "crmne";
    repo = "hyprmoncfg";
    tag = "v${finalAttrs.version}";
    hash = "sha256-hu3ekA4wAp83DE2v00B2n5gsZt2iSv0/OWbg5Mwo4gY=";
  };

  postPatch = ''
    substituteInPlace internal/daemon/daemon_test.go \
      --replace-fail '#!/bin/bash' '#!${lib.getExe bash}'
    substituteInPlace internal/apply/apply_test.go \
      --replace-fail '#!/bin/bash' '#!${lib.getExe bash}' \
      --replace-fail '#!/usr/bin/env bash' '#!${lib.getExe bash}' \
      --replace-fail '#!/bin/sh' '#!${lib.getExe bash}'
    substituteInPlace internal/hypr/client_test.go \
      --replace-fail '#!/usr/bin/env bash' '#!${lib.getExe bash}'
  '';

  nativeBuildInputs = [ makeWrapper ];
  vendorHash = "sha256-gQbjvdKtO0hCXrs9RnWo1s0YeHf5W9t+8AgS2ELXlPo=";
  env.CGO_ENABLED = 0;
  doCheck = true;
  nativeCheckInputs = [ hyprland ];

  preCheck = ''
    export TMPDIR=/tmp
  '';

  postInstall = ''
    install -Dm644 packaging/applications/hyprmoncfg.desktop \
      $out/share/applications/hyprmoncfg.desktop
    install -Dm644 packaging/icons/hyprmoncfg.svg \
      $out/share/icons/hicolor/scalable/apps/hyprmoncfg.svg
    substituteInPlace packaging/systemd/hyprmoncfgd.service \
      --replace-fail /usr/bin/hyprmoncfgd $out/bin/hyprmoncfgd
    install -Dm644 packaging/systemd/hyprmoncfgd.service \
      $out/share/systemd/user/hyprmoncfgd.service
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  postFixup = ''
    wrapProgram $out/bin/hyprmoncfg \
      --prefix PATH : ${lib.makeBinPath [ hyprland ]}
    wrapProgram $out/bin/hyprmoncfgd \
      --prefix PATH : ${lib.makeBinPath [ hyprland ]}
  '';

  __structuredAttrs = true;

  ldflags = [
    "-s"
    "-w"
    "-X github.com/crmne/hyprmoncfg/internal/buildinfo.Version=${finalAttrs.version}"
    "-X github.com/crmne/hyprmoncfg/internal/buildinfo.Commit=0000000"
    "-X github.com/crmne/hyprmoncfg/internal/buildinfo.Date=unknown"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Terminal-first monitor configurator and auto-switching daemon for Hyprland";
    homepage = "https://github.com/crmne/hyprmoncfg";
    changelog = "https://github.com/crmne/hyprmoncfg/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ crmne ];
    platforms = hyprland.meta.platforms;
    mainProgram = "hyprmoncfg";
  };
})
