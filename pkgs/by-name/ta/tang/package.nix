{
  lib,
  stdenv,
  fetchFromGitHub,
  asciidoc-full,
  gitUpdater,
  http-parser,
  jansson,
  jose,
  makeWrapper,
  meson,
  ninja,
  nixosTests,
  pkg-config,
  systemd,
  tang,
  testers,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "tang";
  version = "15";

  src = fetchFromGitHub {
    owner = "latchset";
    repo = "tang";
    tag = "v${finalAttrs.version}";
    hash = "sha256-nlC2hdNzQZrfirjS2gX4oFp2OD1OdxmLsN03hfxD3ug=";
  };

  outputs = [
    "out"
    "man"
  ];

  nativeBuildInputs = [
    asciidoc-full
    meson
    ninja
    pkg-config
    makeWrapper
  ];

  buildInputs = [
    jansson
    jose
    http-parser
    systemd
  ];

  postFixup = ''
    wrapProgram $out/bin/tang-show-keys --prefix PATH ":" ${lib.makeBinPath [ jose ]}
    wrapProgram $out/libexec/tangd-keygen --prefix PATH ":" ${lib.makeBinPath [ jose ]}
    wrapProgram $out/libexec/tangd-rotate-keys --prefix PATH ":" ${lib.makeBinPath [ jose ]}
  '';

  passthru = {
    tests = {
      inherit (nixosTests) tang;

      version = testers.testVersion {
        version = "tangd ${finalAttrs.version}";
        command = "${tang}/libexec/tangd --version";
        package = tang;
      };
    };

    updateScript = gitUpdater { };
  };

  meta = {
    description = "Server for binding data to network presence";
    homepage = "https://github.com/latchset/tang";
    changelog = "https://github.com/latchset/tang/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ fpletz ];
    mainProgram = "tangd";
  };
})
