{
  lib,
  fetchFromGitHub,
  bashInteractive,
  coreutils,
  curl,
  gnugrep,
  gnused,
  makeWrapper,
  nix-update-script,
  procps,
  replaceVars,
  # sniprun-bin
  rustPlatform,
  # sniprun
  vimUtils,
}:
let
  version = "1.3.22";
  src = fetchFromGitHub {
    owner = "michaelb";
    repo = "sniprun";
    tag = "v${version}";
    hash = "sha256-lehL28qI1YArYK38v5tGRe7SSzHxU8Fbf10fG4ShMUw=";
  };
  sniprun-bin = rustPlatform.buildRustPackage {
    inherit version src;
    pname = "sniprun-bin";
    nativeBuildInputs = [ makeWrapper ];
    cargoHash = "sha256-YbovDLXVYnwCWwUC5FNAdvGbBThbkI4kOF5ukDY1IhA=";
    doCheck = false;

    postInstall = ''
      wrapProgram $out/bin/sniprun \
        --prefix PATH ${
          lib.makeBinPath [
            bashInteractive
            coreutils
            curl
            gnugrep
            gnused
            procps
          ]
        }
    '';

    meta.mainProgram = "sniprun";
  };
in
vimUtils.buildVimPlugin {
  inherit version src;
  pname = "sniprun";

  patches = [
    (replaceVars ./fix-paths.patch {
      sniprun = lib.getExe sniprun-bin;
    })
  ];

  propagatedBuildInputs = [ sniprun-bin ];

  passthru = {
    # needed for the update script
    inherit sniprun-bin;

    updateScript = nix-update-script {
      attrPath = "vimPlugins.sniprun.sniprun-bin";
    };
  };

  meta = {
    homepage = "https://github.com/michaelb/sniprun/";
    changelog = "https://github.com/michaelb/sniprun/blob/v${version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ GaetanLepage ];
  };
}
