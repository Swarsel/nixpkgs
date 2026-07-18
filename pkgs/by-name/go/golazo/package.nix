{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  gitUpdater,
  libnotify,
}:
buildGoModule (finalAttrs: {
  pname = "golazo";
  version = "0.26.0";

  src = fetchFromGitHub {
    owner = "0xjuanma";
    repo = "golazo";
    tag = "v${finalAttrs.version}";
    hash = "sha256-g9JPPP/pZ65Jgq2hXYzRynhZebF7s2ZTNU4Ca1Iu5uc=";
  };

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [ libnotify ];
  vendorHash = "sha256-M2gfqU5rOfuiVSZnH/Dr8OVmDhyU2jYkgW7RuIUTd+E=";
  __structuredAttrs = true;

  ldflags = [
    "-X github.com/0xjuanma/golazo/cmd.Version=v${finalAttrs.version}"
  ];

  subPackages = [ "." ];

  passthru.updateScript = gitUpdater {
    rev-prefix = "v";
  };

  meta = {
    description = "Minimal TUI app to keep up with live & recent football/soccer matches written in Go";
    homepage = "https://github.com/0xjuanma/golazo";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ rafaelrc ];
    platforms = lib.platforms.all;
    mainProgram = "golazo";
  };
})
