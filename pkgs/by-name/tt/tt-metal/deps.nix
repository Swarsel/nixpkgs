{ fetchFromGitHub }:
{
  benchmark = fetchFromGitHub {
    hash = "sha256-5xDg1duixLoWIuy59WT0r5ZBAvTR6RPP7YrhBYkMxc8=";
    owner = "google";
    repo = "benchmark";
    tag = "v1.9.1";
  };

  cxxopts = fetchFromGitHub {
    hash = "sha256-2Z8DT9ihlmbiqCi8gcNzW4C5AUh4xCrpCKrGbRYcreQ=";
    owner = "jarro2783";
    repo = "cxxopts";
    rev = "dbf4c6a66816f6c3872b46cc6af119ad227e04e1";
  };

  enchantum = fetchFromGitHub {
    hash = "sha256-q2bbNAMpNJYedekEDtTQ2qI2+GPdkTsuxAHCBaAnuTA=";
    owner = "ZXShady";
    repo = "enchantum";
    rev = "8ca5b0eb7e7ebe0252e5bc6915083f1dd1b8294e";
  };

  flatbuffers = fetchFromGitHub {
    hash = "sha256-uE9CQnhzVgOweYLhWPn2hvzXHyBbFiFVESJ1AEM3BmA=";
    owner = "google";
    repo = "flatbuffers";
    tag = "v24.3.25";
  };

  fmt = fetchFromGitHub {
    hash = "sha256-sUbxlYi/Aupaox3JjWFqXIjcaQa0LFjclQAOleT+FRA=";
    owner = "fmtlib";
    repo = "fmt";
    tag = "11.1.4";
  };

  googletest = fetchFromGitHub {
    hash = "sha256-LVLEn+e7c8013pwiLzJiiIObyrlbBHYaioO/SWbItPQ=";
    owner = "google";
    repo = "googletest";
    tag = "v1.13.0";
  };

  libuv = fetchFromGitHub {
    hash = "sha256-U68BmIQNpmIy3prS7LkYl+wvDJQNikoeFiKh50yQFoA=";
    owner = "libuv";
    repo = "libuv";
    tag = "v1.48.0";
  };

  msgpack = fetchFromGitHub {
    hash = "sha256-VqzFmm3MmMhWyooOsz1d9gwwbn/fnnxpkCFwqKR6los=";
    owner = "msgpack";
    repo = "msgpack-c";
    tag = "cpp-6.1.0";
  };

  nanobind = fetchFromGitHub {
    fetchSubmodules = true;
    hash = "sha256-ex5svqDp9XJtiNCxu0249ORL6LbG679U6PvKQaWANmE=";
    owner = "wjakob";
    repo = "nanobind";
    tag = "v2.7.0";
  };

  nanomsg = fetchFromGitHub {
    hash = "sha256-E2uosZrmxO3fqwlLuu5e36P70iGj5xUlvhEb+1aSvOA=";
    owner = "nanomsg";
    repo = "nng";
    tag = "v1.8.0";
  };

  nlohmann_json = fetchFromGitHub {
    hash = "sha256-7F0Jon+1oWL7uqet5i1IgHX0fUw/+z0QwEcA3zs5xHg=";
    owner = "nlohmann";
    repo = "json";
    tag = "v3.11.3";
  };

  pybind11 = fetchFromGitHub {
    hash = "sha256-SNLdtrOjaC3lGHN9MAqTf51U9EzNKQLyTMNPe0GcdrU=";
    owner = "pybind";
    repo = "pybind11";
    tag = "v2.13.6";
  };

  range-v3 = fetchFromGitHub {
    hash = "sha256-bRSX91+ROqG1C3nB9HSQaKgLzOHEFy9mrD2WW3PRBWU=";
    owner = "ericniebler";
    repo = "range-v3";
    tag = "0.12.0";
  };

  reflect = fetchFromGitHub {
    hash = "sha256-qjy5KyAm7/WeCyxMu/5QrBVjDSJPs0q/ZPyQwXp0WLA=";
    owner = "boost-ext";
    repo = "reflect";
    tag = "v1.2.6";
  };

  simd-everywhere = fetchFromGitHub {
    hash = "sha256-igjDHCpKXy6EbA9Mf6peL4OTVRPYTV0Y2jbgYQuWMT4=";
    owner = "simd-everywhere";
    repo = "simde";
    tag = "v0.8.2";
  };

  spdlog = fetchFromGitHub {
    hash = "sha256-9RhB4GdFjZbCIfMOWWriLAUf9DE/i/+FTXczr0pD0Vg=";
    owner = "gabime";
    repo = "spdlog";
    tag = "v1.15.2";
  };

  taskflow = fetchFromGitHub {
    hash = "sha256-q2IYhG84hPIZhuogWf6ojDG9S9ZyuJz9s14kQyIc6t0=";
    owner = "taskflow";
    repo = "taskflow";
    tag = "v3.7.0";
  };

  tokenizers-cpp = fetchFromGitHub {
    hash = "sha256-CkW8S6LHHOY+tz3hHoWBzwGb3f25LFp41F/jH4pdKI4=";
    owner = "mlc-ai";
    repo = "tokenizers-cpp";
    rev = "55d53aa38dc8df7d9c8bd9ed50907e82ae83ce66";
  };

  tt-logger = fetchFromGitHub {
    hash = "sha256-lw8L4pCAGObCkiuF/JFC9PmcQgwmJZOOo1cbaUMvo+I=";
    owner = "tenstorrent";
    repo = "tt-logger";
    tag = "v1.1.5";
  };

  xtensor = fetchFromGitHub {
    hash = "sha256-gAGLb5NPT4jiIpXONqY+kalxKCFKFXlNqbM79x1lTKE=";
    owner = "xtensor-stack";
    repo = "xtensor";
    tag = "0.26.0";
  };

  xtensor-blas = fetchFromGitHub {
    hash = "sha256-Lg6MjJbZUCMqv4eSiZQrLfJy/86RWQ9P85UfeIQJ6bk=";
    owner = "xtensor-stack";
    repo = "xtensor-blas";
    tag = "0.22.0";
  };

  xtl = fetchFromGitHub {
    hash = "sha256-hhXM2fG3Yl4KeEJlOAcNPVLJjKy9vFlI63lhbmIAsT8=";
    owner = "xtensor-stack";
    repo = "xtl";
    tag = "0.8.0";
  };

  yaml-cpp = fetchFromGitHub {
    hash = "sha256-J87oS6Az1/vNdyXu3L7KmUGWzU0IAkGrGMUUha+xDXI=";
    owner = "jbeder";
    repo = "yaml-cpp";
    tag = "0.8.0";
  };
}
