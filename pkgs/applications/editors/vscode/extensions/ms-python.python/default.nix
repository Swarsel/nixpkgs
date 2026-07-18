{
  lib,
  stdenv,
  icu,
  python3,
  # For updateScript
  vscode-extension-update-script,
  vscode-utils,
  # When `true`, the python default setting will be fixed to specified.
  # Use version from `PATH` for default setting otherwise.
  # Defaults to `false` as we expect it to be project specific most of the time.
  pythonUseFixed ? false,
}:

let
  supported = {
    aarch64-darwin = {
      arch = "darwin-arm64";
      hash = "sha256-XntiQmvagiSWcfVIp13CDq2RTZ4NhKOzf4QmecZjMIs=";
    };

    aarch64-linux = {
      arch = "linux-arm64";
      hash = "sha256-v7fatW/LMJ8CeSRrE/5b7dLqOrhNhwzUySUxtAMuBUE=";
    };

    x86_64-linux = {
      arch = "linux-x64";
      hash = "sha256-HQfmDV6rJX6l1pGybe8//2QrTSwE+rlEJOi4/iW69lY=";
    };
  };

  base =
    supported.${stdenv.hostPlatform.system}
      or (throw "unsupported platform ${stdenv.hostPlatform.system}");

in
vscode-utils.buildVscodeMarketplaceExtension {
  postPatch = ''
    # remove bundled python deps and use libs from nixpkgs
    rm -r python_files/lib
    mkdir -p python_files/lib/python/
    ln -s ${python3.pkgs.debugpy}/lib/*/site-packages/debugpy python_files/lib/python/
    buildPythonPath "$propagatedBuildInputs"
    for i in python_files/*.py; do
      patchPythonScript "$i"
    done
  ''
  + lib.optionalString pythonUseFixed ''
    # Patch `packages.json` so that nix's *python* is used as default value for `python.pythonPath`.
    substituteInPlace "./package.json" \
      --replace-fail "\"default\":\"python\"" "\"default\":\"${python3.interpreter}\""
  '';

  nativeBuildInputs = [ python3.pkgs.wrapPython ];
  buildInputs = [ icu ];

  propagatedBuildInputs = with python3.pkgs; [
    debugpy
    jedi-language-server
  ];

  mktplcRef = base // {
    version = "2026.4.0";
    name = "python";
    publisher = "ms-python";
  };

  passthru.updateScript = vscode-extension-update-script { };

  meta = {
    description = "Visual Studio Code extension with rich support for the Python language";
    homepage = "https://github.com/Microsoft/vscode-python";
    changelog = "https://github.com/microsoft/vscode-python/releases";
    license = lib.licenses.mit;

    maintainers = [
      lib.maintainers.jraygauthier
    ];

    platforms = builtins.attrNames supported;
    downloadPage = "https://marketplace.visualstudio.com/items?itemName=ms-python.python";
  };
}
