{
  lib,
  fetchFromGitHub,
  bashInteractive,
  buildPythonPackage,
  cryptography,
  diffstat,
  keyring,
  rpm,
  ruamel-yaml,
  urllib3,
}:

buildPythonPackage rec {
  pname = "osc";
  version = "1.27.2";

  src = fetchFromGitHub {
    owner = "openSUSE";
    repo = "osc";
    rev = version;
    hash = "sha256-PwOJpjlIqOtLw79DK0KWb8ktAQ9vQVnSdf657jPVfLQ=";
  };

  buildInputs = [ bashInteractive ]; # needed for bash-completion helper

  propagatedBuildInputs = [
    urllib3
    cryptography
    keyring
    ruamel-yaml
  ];

  nativeCheckInputs = [
    rpm
    diffstat
  ];

  preCheck = "HOME=$TOP/tmp";

  postInstall = ''
    install -D -m444 contrib/osc.fish $out/etc/fish/completions/osc.fish
    install -D -m555 contrib/osc.complete $out/share/bash-completion/helpers/osc-helper
    mkdir -p $out/share/bash-completion/completions
    cat >>$out/share/bash-completion/completions/osc <<EOF
    test -z "\$BASH_VERSION" && return
    complete -o default _nullcommand >/dev/null 2>&1 || return
    complete -r _nullcommand >/dev/null 2>&1         || return
    complete -o default -C $out/share/bash-completion/helpers/osc-helper osc
    EOF
  '';

  format = "setuptools";

  meta = {
    description = "Opensuse-commander with svn like handling";
    homepage = "https://github.com/openSUSE/osc";
    license = lib.licenses.gpl2;

    maintainers = with lib.maintainers; [
      peti
      saschagrunert
    ];

    mainProgram = "osc";
  };
}
