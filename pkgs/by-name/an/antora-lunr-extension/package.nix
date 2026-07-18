{
  lib,
  fetchFromGitLab,
  antora,
  buildNpmPackage,
  nix-update-script,
}:
buildNpmPackage rec {
  pname = "antora-lunr-extension";
  version = "1.0.0-alpha.8";

  src = fetchFromGitLab {
    owner = "antora";
    repo = "antora-lunr-extension";
    tag = "v${version}";
    hash = "sha256-GplCwhUl8jurD4FfO6/T3Vo1WFjg+rtAjWeIh35unk4=";
  };

  # Prevent tests from failing because they are fetching data at runtime.
  postPatch = ''
    substituteInPlace package.json --replace '"_mocha"' '""'
  '';

  npmDepsHash = "sha256-EtjZL6U/uSGSYSqtuatCkdWP0NHxRuht13D9OaM4x00=";

  # Pointing $out to $out/lib/node_modules/@antora/lunr-extension simplifies
  # Antora's extension option usage from
  #
  #     --extension ${pkgs.antora-lunr-extension}/lib/node_modules/@antora/lunr-extension
  #
  # to
  #
  #     --extension ${pkgs.antora-lunr-extension}
  postInstall = ''
    directory="$(mktemp --directory)"

    mv "$out/"{.,}* "$directory"
    mv "$directory/lib/node_modules/@antora/lunr-extension/"{.,}* "$out"
  '';

  passthru = {
    tests.run = antora.tests.run.override {
      antora-lunr-extension-test = true;
    };

    updateScript = nix-update-script { };
  };

  meta = {
    description = "Antora extension adding offline, full-text search powered by Lunr";

    longDescription = ''
      This Antora extension is intended to be passed to `antora`'s `--extension`
      flag or injected into the [`antora.extensions`
      key](https://docs.antora.org/antora/3.1/extend/enable-extension).
    '';

    homepage = "https://gitlab.com/antora/antora-lunr-extension";
    license = lib.licenses.mpl20;
    maintainers = [ lib.maintainers.noahbiewesch ];
    platforms = lib.platforms.all;
  };
}
