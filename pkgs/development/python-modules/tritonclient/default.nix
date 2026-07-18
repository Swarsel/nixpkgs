{
  lib,
  stdenv,
  # optional dependencies
  aiohttp,
  buildPythonPackage,
  fetchPypi,
  geventhttpclient,
  grpcio,
  numpy,
  packaging,
  python-rapidjson,
  urllib3,
}:

let
  pname = "tritonclient";
  version = "2.68.0";
  format = "wheel";
in
buildPythonPackage rec {
  inherit pname version format;

  src =
    let
      platforms = {
        aarch64-linux = "manylinux2014_aarch64";
        x86_64-linux = "manylinux1_x86_64";
      };
      hashes = {
        aarch64-linux = "sha256-RkHdD4yPvo85Fqts07XFsgiMUCFXWiWuHQqfGDznJGk=";
        x86_64-linux = "sha256-7h98H/ipZk56193fhhaSR62Mnis4Wakn/ZhOrhWa4vc=";
      };
    in
    fetchPypi {
      inherit pname version format;

      hash =
        hashes.${stdenv.hostPlatform.system} or (throw "Unsupported system: ${stdenv.hostPlatform.system}");

      dist = "py3";

      platform =
        platforms.${stdenv.hostPlatform.system}
          or (throw "Unsupported system: ${stdenv.hostPlatform.system}");

      python = "py3";
    };

  propagatedBuildInputs = [
    numpy
    python-rapidjson
    urllib3
  ];

  pythonImportsCheck = [ "tritonclient" ];

  passthru = {
    optional-dependencies = {
      grpc = [
        grpcio
        packaging
      ];

      http = [
        aiohttp
        geventhttpclient
      ];
    };
  };

  meta = {
    description = "Triton Python client";
    homepage = "https://github.com/triton-inference-server/client";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ happysalada ];
    platforms = lib.platforms.linux;
  };
}
