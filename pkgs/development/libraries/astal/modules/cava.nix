{
  buildAstalModule,
  fftw,
  libcava,
}:
buildAstalModule {
  buildInputs = [
    libcava
    fftw
  ];

  name = "cava";
  meta.description = "Astal module for audio visualization using cava";
}
