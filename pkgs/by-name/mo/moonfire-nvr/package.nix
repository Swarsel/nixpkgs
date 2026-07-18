{
  lib,
  fetchFromGitHub,
  callPackage,
  moonfire-nvr,
  ncurses,
  nix-update,
  pkg-config,
  rustPlatform,
  sqlite,
  testers,
  writeShellApplication,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "moonfire-nvr";
  version = "0.7.31";

  src = fetchFromGitHub {
    owner = "scottlamb";
    repo = "moonfire-nvr";
    tag = "v${finalAttrs.version}";
    hash = "sha256-QgsaiWcXeU4y7z9mcqUAl4mQ/M4p38yRjOB/4MKlpVA=";
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    ncurses
    sqlite
  ];

  cargoHash = "sha256-TDFe5pD+8eSwvw0h9GLM+JfODlSBU1CO8fw4FVjy8xk=";
  env.VERSION = "v${finalAttrs.version}";
  doCheck = false;

  postInstall = ''
    mkdir -p $out/lib
    ln -s ${moonfire-nvr.ui} $out/lib/ui
  '';

  sourceRoot = "${finalAttrs.src.name}/server";

  passthru = {
    tests.version = testers.testVersion {
      version = "Version: v${finalAttrs.version}";
      command = "moonfire-nvr --version";
      package = moonfire-nvr;
    };

    ui = callPackage ./ui.nix { };

    updateScript = lib.getExe (writeShellApplication {
      name = "update-moonfire-nvr";

      runtimeInputs = [
        nix-update
      ];

      text = ''
        set -euo pipefail

        nix-update moonfire-nvr
        nix-update moonfire-nvr.ui --version=skip
      '';
    });
  };

  meta = {
    description = "Moonfire NVR, a security camera network video recorder";
    homepage = "https://github.com/scottlamb/moonfire-nvr";
    changelog = "https://github.com/scottlamb/moonfire-nvr/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.gpl3Only;
    maintainers = [ ];
    mainProgram = "moonfire-nvr";
  };
})
