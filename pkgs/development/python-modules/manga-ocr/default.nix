{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  fire,
  fugashi,
  jaconv,
  loguru,
  numpy,
  pillow,
  pyperclip,
  setuptools,
  setuptools-scm,
  torch,
  transformers,
  unidic-lite,
}:

buildPythonPackage rec {
  pname = "manga-ocr";
  version = "0.1.14";

  src = fetchFromGitHub {
    owner = "kha-white";
    repo = "manga-ocr";
    tag = "v${version}";
    hash = "sha256-fCLgFeo6GYPSpCX229TK2MXTKt3p1tQV06phZYD6UeE=";
  };

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    fire
    fugashi
    jaconv
    loguru
    numpy
    pillow
    pyperclip
    torch
    transformers
    unidic-lite
  ];

  pyproject = true;

  meta = {
    description = "Optical character recognition for Japanese text, with the main focus being Japanese manga";
    homepage = "https://github.com/kha-white/manga-ocr";
    changelog = "https://github.com/kha-white/manga-ocr/releases/tag/${src.tag}";
    license = lib.licenses.asl20;
    maintainers = [ ];
    mainProgram = "manga_ocr";
  };
}
