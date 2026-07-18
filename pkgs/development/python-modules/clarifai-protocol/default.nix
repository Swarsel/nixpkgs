{
  lib,
  stdenv,
  buildPythonPackage,
  fetchPypi,
  grpcio,
  pypaInstallHook,
  python,
  wheelUnpackHook,
}:

let
  pythonVersionNoDot = builtins.replaceStrings [ "." ] [ "" ] python.pythonVersion;
  systemToPlatform = {
    "aarch64-darwin" = "macosx_11_0_universal2";
    "aarch64-linux" = "manylinux_2_17_aarch64.manylinux2014_aarch64";
    "x86_64-linux" = "manylinux_2_17_x86_64.manylinux2014_x86_64";
  };

  key =
    if stdenv.hostPlatform.isDarwin then
      "${pythonVersionNoDot}-darwin"
    else
      "${pythonVersionNoDot}-${stdenv.hostPlatform.system}";

  hash =
    {
      "310-aarch64-linux" = "sha256-uLHEEPcVakctNT428pNlaq0yKDpvMLynDP2lDobiebA=";
      "310-darwin" = "sha256-80U0geHKJLVhhmvHayXWHWaV9ifJjWtR9mbwCUDfPu0=";
      "310-x86_64-linux" = "sha256-1SO/1lpB3aRWisxFlt8K5lwFEOiDXjC4iQRai77L+8E=";
      "311-aarch64-linux" = "sha256-d2A4mKP4Dlnm6J31wPyAHg8d5MjFF4wcREe5FVFeayU=";
      "311-darwin" = "sha256-kM2YVzPa22QgIRV4zP4kcvTE8al/RW0Oo6lyxJl3JxU=";
      "311-x86_64-linux" = "sha256-99VdM1fAcuiblReWL5I8+H0psCKR00HYZr/wRGT7nd8=";
      "312-aarch64-linux" = "sha256-aW295fQogAjaVK6saHhduKsVsncIv4BsfRW6qHlyb3g=";
      "312-darwin" = "sha256-t4qbP5wqE8cgkvN+vG6zOeS+s5+U/GjmbeeHytIo9/o=";
      "312-x86_64-linux" = "sha256-bbggF4rGDrXOpSegreFHgK0H/z7xaR9hb7z6SYp7nlU=";
      "313-aarch64-linux" = "sha256-mloW8TGkBJWXqO6xOqHhra3ZXuGQWf6dEGSrkdD0sb0=";
      "313-darwin" = "sha256-ds2kj87miODVUE8Lrjuzz8L+2HxaQ7jTxGQF0/Odrpg=";
      "313-x86_64-linux" = "sha256-M9/t7JgIjh7yiZeEq9K2tGQ4oLneVhXf0rUfL8p09Tg=";
      "314-aarch64-linux" = "";
      "314-darwin" = "";
      "314-x86_64-linux" = "";
      "39-aarch64-linux" = "sha256-wuEncCbqWdqO72zovzHrmb34on73eaQgFBmQZdUnwkE=";
      "39-darwin" = "sha256-uU9RGo5glYOPp8nEYqj4c1TB3Xa1KwrNWMqNDpJsSjY=";
      "39-x86_64-linux" = "sha256-uGbsxSHGfYVzRiy1YEkQMkJi2yPLdSj3fe3adp1WjP0=";
    }
    .key or (throw "clarifai-protocol: unsupported system/python (${key}) version combination");
in
buildPythonPackage rec {
  pname = "clarifai-protocol";
  version = "0.0.14";

  src = fetchPypi {
    inherit version;
    inherit hash;
    abi = "cp${pythonVersionNoDot}";
    dist = "cp${pythonVersionNoDot}";
    format = "wheel";
    platform = systemToPlatform.${stdenv.hostPlatform.system} or (throw "unsupported system");
    pname = "clarifai_protocol";
    python = "cp${pythonVersionNoDot}";
  };

  nativeBuildInputs = [
    pypaInstallHook
    wheelUnpackHook
  ];

  # no tests
  doCheck = false;
  dependencies = [ grpcio ];
  # require clarifai and it causes a circular import
  dontUsePythonImportsCheck = true;
  pyproject = false;

  meta = {
    description = "Clarifai Python Runner Protocol";
    homepage = "https://pypi.org/project/clarifai-protocol";
    license = lib.licenses.asl20;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    maintainers = with lib.maintainers; [ natsukium ];
  };
}
