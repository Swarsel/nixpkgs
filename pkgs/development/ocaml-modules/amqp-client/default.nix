{
  lib,
  fetchFromGitHub,
  buildDunePackage,
  version ? "2.3.0",
}:

buildDunePackage {
  inherit version;
  pname = "amqp-client";

  src = fetchFromGitHub {
    owner = "andersfugmann";
    repo = "amqp-client";
    tag = version;
    hash = "sha256-zWhkjVoKyNCIBXD5746FywCg3DKn1mXb1tn1VlF9Tyg=";
  };

  doCheck = true;
  minimalOCamlVersion = "4.14.0";

  meta = {
    description = "Amqp client base library";

    longDescription = ''
      This library provides high level client bindings for amqp. The library
      is tested with rabbitmq, but should work with other amqp
      servers. The library is written in pure OCaml.

      This is the base library required by lwt/async versions.
      You should install either amqp-client-async or amqp-client-lwt
      for actual client functionality.
    '';

    homepage = "https://github.com/andersfugmann/amqp-client";
    changelog = "https://raw.githubusercontent.com/andersfugmann/amqp-client/refs/tags/${version}/Changelog";
    license = lib.licenses.bsd3;
    maintainers = [ ];
  };
}
