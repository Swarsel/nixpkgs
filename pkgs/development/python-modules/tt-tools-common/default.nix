{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  distro,
  elasticsearch,
  psutil,
  pydantic,
  pyyaml,
  requests,
  rich,
  setuptools,
  setuptools-scm,
  textual,
  tomli,
  tqdm,
}:
buildPythonPackage rec {
  pname = "tt-tools-common";
  version = "1.6.0";

  src = fetchFromGitHub {
    owner = "tenstorrent";
    repo = "tt-tools-common";
    tag = "v${version}";
    hash = "sha256-xy1UxETmuuqDmZYf67+qx8Yr8tWQ6VKmjb3md8IaInE=";
  };

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    distro
    elasticsearch
    psutil
    pyyaml
    rich
    textual
    requests
    tomli
    tqdm
    pydantic
  ];

  pyproject = true;

  meta = {
    description = "Helper library for common utilities shared across Tentorrent tools";
    homepage = "https://github.com/tenstorrent/tt-tools-common";
    license = with lib.licenses; [ asl20 ];
    maintainers = with lib.maintainers; [ RossComputerGuy ];
  };
}
