{
  lib,
  stdenv,
  autoPatchelfHook,
  fetchPypi,
  python3Packages,
  zlib,
}:

let
  inherit (stdenv.hostPlatform) system;
in
python3Packages.buildPythonApplication (finalAttrs: {
  pname = "sourcery";
  version = "1.43.0";
  src = finalAttrs.passthru.sources.${system} or (throw "Unsupported platform ${system}");
  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [ autoPatchelfHook ];
  buildInputs = [ zlib ];
  format = "wheel";

  passthru.sources =
    let
      fetchWheel =
        { hash, platform }:
        fetchPypi {
          inherit (finalAttrs) pname version;
          inherit platform hash;
          format = "wheel";
        };
    in
    {
      "aarch64-darwin" = fetchWheel {
        hash = "sha256-iQNOSoAClAk2FMjAExfgsFHDXS56vwieePGDCYRRbgQ=";
        platform = "macosx_11_0_arm64";
      };

      "x86_64-linux" = fetchWheel {
        hash = "sha256-oUL7EVbfwgV1K1Rv0kzW5r1AXr167BCXwzntDgVyTc0=";
        platform = "manylinux1_x86_64";
      };
    };

  meta = {
    description = "AI-powered code review and pair programming tool for Python";
    homepage = "https://sourcery.ai";
    changelog = "https://sourcery.ai/changelog/";
    license = lib.licenses.unfree;
    maintainers = with lib.maintainers; [ tomasajt ];
    platforms = lib.attrNames finalAttrs.passthru.sources;
    mainProgram = "sourcery";
    downloadPage = "https://pypi.org/project/sourcery/";
  };
})
