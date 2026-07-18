{
  lib,
  ruff,
  stdenvNoCC,
  vscode-extension-update-script,
  vscode-utils,
}:

vscode-utils.buildVscodeMarketplaceExtension {
  postInstall = ''
    test -x "$out/$installPrefix/bundled/libs/bin/ruff" || {
      echo "Replacing the bundled ruff binary failed, because 'bundled/libs/bin/ruff' is missing."
      echo "Update the package to the match the new path/behavior."
      exit 1
    }
    ln -sf ${lib.getExe ruff} "$out/$installPrefix/bundled/libs/bin/ruff"
  '';

  mktplcRef =
    let
      sources = {
        "aarch64-darwin" = {
          arch = "darwin-arm64";
          hash = "sha256-wEp7kaEnkdBl44WjKuDBjR5SEjYNdgIX7DdJWKvv6I4=";
        };

        "aarch64-linux" = {
          arch = "linux-arm64";
          hash = "sha256-iuYVCG4YWPFI8o4GmuNjkbXvzJsAre0gSSEWq6CUk2E=";
        };

        "x86_64-linux" = {
          arch = "linux-x64";
          hash = "sha256-lhDt8XEF90y4pj8RLUZgfZNmHkV1XlmHsYuT6sGJMRc=";
        };
      };
    in
    {
      version = "2026.54.0";
      name = "ruff";
      publisher = "charliermarsh";
    }
    // sources.${stdenvNoCC.hostPlatform.system}
      or (throw "Unsupported system ${stdenvNoCC.hostPlatform.system}");

  passthru.updateScript = vscode-extension-update-script { };

  meta = {
    description = "Visual Studio Code extension with support for the Ruff linter";
    homepage = "https://github.com/astral-sh/ruff-vscode";
    changelog = "https://marketplace.visualstudio.com/items/charliermarsh.ruff/changelog";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.azd325 ];

    platforms = [
      "aarch64-linux"
      "aarch64-darwin"
      "x86_64-linux"
    ];

    downloadPage = "https://marketplace.visualstudio.com/items?itemName=charliermarsh.ruff";
  };
}
