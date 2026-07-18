{
  lib,
  stdenv,
  fetchFromGitHub,
  ncurses,
  nixosTests,
  pcre2,
  perl,
  php82,
  python3,
  which,
  openssl ? null,
  withDebug ? false,
  withIPv6 ? true,
  withPHP82 ? true,
  withPerl ? true,
  withPython3 ? true,
  withSSL ? true,
}:

let
  phpConfig = {
    apxs2Support = false;
    cgiSupport = false;
    embedSupport = true;
    fpmSupport = false;
    phpdbgSupport = false;
    systemdSupport = false;
  };

  php82-unit = php82.override phpConfig;

  inherit (lib) optional optionals optionalString;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "unit";
  version = "1.35.0";

  src = fetchFromGitHub {
    owner = "nginx";
    repo = "unit";
    rev = finalAttrs.version;
    sha256 = "sha256-0cMtU7wmy8GFKqxS8fXPIrMljYXBHzoxrUJCOJSzLMA=";
  };

  nativeBuildInputs = [ which ];

  buildInputs = [
    pcre2.dev
  ]
  ++ optionals withPython3 [
    python3
    ncurses
  ]
  ++ optional withPHP82 php82-unit
  ++ optional withPerl perl
  ++ optional withSSL openssl;

  configureFlags = [
    "--control=unix:/run/unit/control.unit.sock"
    "--pid=/run/unit/unit.pid"
    "--user=unit"
    "--group=unit"
  ]
  ++ optional withSSL "--openssl"
  ++ optional (!withIPv6) "--no-ipv6"
  ++ optional withDebug "--debug";

  env.NIX_CFLAGS_COMPILE = toString [
    # 'EVP_PKEY_asn1_find_str' is deprecated since OpenSSL 3.6
    "-Wno-error=deprecated-declarations"
  ];

  postConfigure = ''
    ${optionalString withPython3 "./configure python --module=python3  --config=python3-config  --lib-path=${python3}/lib"}
    ${optionalString withPHP82 "./configure php    --module=php82    --config=${php82-unit.unwrapped.dev}/bin/php-config --lib-path=${php82-unit}/lib"}
    ${optionalString withPerl "./configure perl   --module=perl     --perl=${perl}/bin/perl"}
  '';

  # Optionally add the PHP derivations used so they can be addressed in the configs
  usedPhp82 = optionals withPHP82 php82-unit;

  passthru.tests = {
    unit-perl = nixosTests.unit-perl;
    unit-php = nixosTests.unit-php;
  };

  meta = {
    description = "Dynamic web and application server, designed to run applications in multiple languages";
    homepage = "https://unit.nginx.org/";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ izorkin ];
    platforms = lib.platforms.linux;
    mainProgram = "unitd";
  };
})
