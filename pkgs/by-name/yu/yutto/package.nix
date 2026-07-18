{
  lib,
  fetchFromGitHub,
  ffmpeg,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "yutto";
  version = "2.2.0";

  src = fetchFromGitHub {
    owner = "yutto-dev";
    repo = "yutto";
    tag = "v${finalAttrs.version}";
    hash = "sha256-5p0/a7cwmXqQVQP90cgwWHFpFaT+YDGDFbN+EGH89CA=";
  };

  postPatch = ''
    sed -ie 's/requires = \["uv_build[^"]*"]/requires = ["uv_build"]/' pyproject.toml
  '';

  preFixup = ''
    makeWrapperArgs+=(--prefix PATH : ${lib.makeBinPath [ ffmpeg ]})
  '';

  build-system = with python3Packages; [ uv-build ];

  dependencies =
    with python3Packages;
    [
      aiofiles
      biliass
      dict2xml
      httpx
      typing-extensions
      pydantic
      returns
      segno
    ]
    ++ (with httpx.optional-dependencies; http2 ++ socks);

  pyproject = true;
  pythonImportsCheck = [ "yutto" ];
  pythonRelaxDeps = true;

  meta = {
    description = "Bilibili downloader";
    homepage = "https://github.com/yutto-dev/yutto";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ linsui ];
    mainProgram = "yutto";
  };
})
