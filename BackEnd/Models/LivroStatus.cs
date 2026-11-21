namespace BookLog.Models;

public static class LivroStatus
{
    public const string QueroLer = "QueroLer";
    public const string Lendo = "Lendo";
    public const string Lido = "Lido";

    public static bool IsValid(string status) =>
        status is QueroLer or Lendo or Lido;

    public static void Validate(string status)
    {
        if (!IsValid(status))
            throw new ArgumentException("Status inválido. Use QueroLer, Lendo ou Lido.");
    }

    public static void Apply(Livro livro, string status)
    {
        Validate(status);
        livro.Status = status;
        livro.Concluido = status == Lido;
        if (livro.Concluido)
            livro.PaginasLidas = livro.TotalPaginas;
    }

    public static string FromProgress(Livro livro) =>
        livro.Concluido ? Lido : livro.PaginasLidas > 0 ? Lendo : QueroLer;
}
