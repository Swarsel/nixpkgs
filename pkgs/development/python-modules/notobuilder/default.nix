{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  chevron,
  diffenator2,
  fontbakery,
  fontmake,
  fonttools,
  gftools,
  glyphslib,
  ninja,
  setuptools,
  setuptools-scm,
  sh,
  ttfautohint-py,
  ufo2ft,
  ufomerge,
  unstableGitUpdater,
}:

buildPythonPackage {
  pname = "notobuilder";
  version = "0-unstable-2026-02-25";

  src = fetchFromGitHub {
    owner = "notofonts";
    repo = "notobuilder";
    rev = "5c15f266be1f24587adad807e2f1f3ff9ff537a8";
    hash = "sha256-Tw1riTHORtIpOq8PjSspIR044TBupYgXkI8fBiBkgJI=";
  };

  postPatch = ''
    substituteInPlace Lib/notobuilder/__main__.py \
      --replace-fail '"ninja"' '"${lib.getExe ninja}"'
  '';

  env.SETUPTOOLS_SCM_PRETEND_VERSION = "0.0.0";

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    fonttools
    ufomerge
    fontmake
    glyphslib
    ttfautohint-py
    ufo2ft
    gftools
    fontbakery
    chevron
    sh
  ]
  ++ gftools.optional-dependencies.qa;

  pyproject = true;

  pythonImportsCheck = [
    "notobuilder"
    "notoqa"
  ];

  passthru.updateScript = unstableGitUpdater { };

  meta = {
    description = "Python module for building Noto fonts";
    homepage = "https://github.com/notofonts/notobuilder";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ jopejoe1 ];
  };
}
