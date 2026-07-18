{
  lib,
  stdenv,
  autoPatchelfHook,
  buildPythonPackage,
  fetchPypi,
  python,
  zlib,
}:
let
  pythonVersionNoDot = builtins.replaceStrings [ "." ] [ "" ] python.pythonVersion;
  inherit (stdenv.hostPlatform) system;
  releases = lib.importJSON ./releases.json;
in
buildPythonPackage rec {
  inherit (releases) version;
  pname = "saxonche";

  src = fetchPypi {
    inherit version;
    hash = releases."cp${pythonVersionNoDot}-${system}".hash or (throw "unsupported system");
    abi = "cp${pythonVersionNoDot}";
    dist = "cp${pythonVersionNoDot}";
    format = "wheel";
    platform = releases."cp${pythonVersionNoDot}-${system}".platform or (throw "unsupported system");
    pname = "saxonche";
    python = "cp${pythonVersionNoDot}";
  };

  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [ autoPatchelfHook ];

  buildInputs = [
    zlib
  ];

  dontBuild = true;
  format = "wheel";
  pythonImportsCheck = [ "saxonche" ];
  passthru.updateScript = ./update.py;

  meta = {
    description = "Official Python package for the SaxonC-HE processor";
    homepage = "https://www.saxonica.com/saxon-c/index.xml";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ hhr2020 ];
  };
}
