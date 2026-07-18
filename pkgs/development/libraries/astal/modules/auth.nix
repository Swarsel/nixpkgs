{
  buildAstalModule,
  pam,
}:
buildAstalModule {
  buildInputs = [ pam ];
  name = "auth";
  meta.description = "Astal module for authentication using pam";
}
