{ lib, fetchFromGitHub }:

rec {
  version = "1.3.0";

  src = fetchFromGitHub {
    owner = "savonet";
    repo = "ocaml-ffmpeg";
    tag = "v${version}";
    hash = "sha256-qGXuE+wHNuy24jeuGpvMlYIQw7N5g6tXMa7r0pwXVX0=";
  };

  meta = {
    description = "Bindings for the ffmpeg libraries";
    homepage = "https://github.com/savonet/ocaml-ffmpeg";
    changelog = "https://raw.githubusercontent.com/savonet/ocaml-ffmpeg/refs/tags/${src.tag}/CHANGES";
    license = lib.licenses.lgpl21Only;

    maintainers = with lib.maintainers; [
      dandellion
      juaningan
    ];
  };
}
