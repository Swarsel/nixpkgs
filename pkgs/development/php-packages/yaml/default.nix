{
  lib,
  buildPecl,
  libyaml,
}:

buildPecl {
  pname = "yaml";
  version = "2.2.5";

  buildInputs = [
    libyaml
  ];

  configureFlags = [ "--with-yaml=${libyaml.dev}" ];
  sha256 = "sha256-DHUbSJdJ+/AgcdWwxr/rJsS4Y8Zo74lxHs+VBzkb33E=";

  meta = {
    description = "YAML-1.1 parser and emitter";
    homepage = "https://github.com/php/pecl-file_formats-yaml";
    license = lib.licenses.mit;
    teams = [ lib.teams.php ];
  };
}
