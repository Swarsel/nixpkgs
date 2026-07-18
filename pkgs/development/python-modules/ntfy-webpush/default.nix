{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  py-vapid,
  pywebpush,
  setuptools,
}:

buildPythonPackage rec {
  pname = "ntfy-webpush";
  version = "0.1.3";

  src = fetchFromGitHub {
    owner = "dschep";
    repo = "ntfy-webpush";
    tag = "v${version}";
    hash = "sha256-VvQ/kCrq7KSMQdYb8p5P0REdek5oNhjslB45+gbetLc=";
  };

  postPatch = ''
    # break dependency loop
    substituteInPlace setup.py \
      --replace-fail "'ntfy', " ""
  '';

  # no tests, just a script
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    pywebpush
    py-vapid
  ];

  pyproject = true;

  meta = {
    description = "Cloudbell webpush notification support for ntfy";
    homepage = "https://dschep.github.io/ntfy-webpush/";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
