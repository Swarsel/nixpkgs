{
  lib,
  fetchFromGitHub,
  buildPecl,
  pkg-config,
  zstd,
}:

let
  version = "0.15.2";
in
buildPecl {
  inherit version;
  pname = "zstd";

  src = fetchFromGitHub {
    owner = "kjdev";
    repo = "php-ext-zstd";
    rev = version;
    hash = "sha256-NGbrbvW2kNhgj3nqqjGLqowcp9EKqYffR1DOBIzdXeA=";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ zstd ];
  configureFlags = [ "--with-libzstd" ];

  meta = {
    description = "Zstd Extension for PHP";
    homepage = "https://github.com/kjdev/php-ext-zstd";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
