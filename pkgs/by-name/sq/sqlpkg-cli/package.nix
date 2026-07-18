{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "sqlpkg-cli";
  version = "0.2.3";

  src = fetchFromGitHub {
    owner = "nalgeon";
    repo = "sqlpkg-cli";
    tag = finalAttrs.version;
    hash = "sha256-qytqTaoslBcoIn84tSiLABwRcnY/FsyWYD3sugGEYB0=";
  };

  vendorHash = null;

  preCheck = ''
    export HOME="$TMP"
  '';

  postInstall = ''
    mv -v $out/bin/cli $out/bin/sqlpkg
  '';

  ldflags = [
    "-s"
    "-w"
  ];

  meta = {
    description = "SQLite package manager";
    homepage = "https://github.com/nalgeon/sqlpkg-cli";
    changelog = "https://github.com/nalgeon/sqlpkg-cli/releases/tag/${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.pbsds ];
    platforms = lib.platforms.unix;

    badPlatforms = [
      "aarch64-linux" # assets_test.go:44: BuildAssetPath: unexpected error unsupported platform: linux-arm64
      "aarch64-darwin" # install_test.go:22: installation error: failed to dequarantine files: exec: "xattr": executable file not found in $PATH
    ];

    mainProgram = "sqlpkg";
  };
})
