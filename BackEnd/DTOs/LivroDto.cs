using System.ComponentModel.DataAnnotations;

namespace BookLog.DTOs;

public class LivroDto
{
    public int Id { get; set; }
    public string Titulo { get; set; } = string.Empty;
    public string? Autor { get; set; }
    public string? Genero { get; set; }
    public int TotalPaginas { get; set; }
    public int PaginasLidas { get; set; }
    public bool Concluido { get; set; }
    public DateTime DataCadastro { get; set; }
    public double Percentual => TotalPaginas > 0 ? Math.Round((double)PaginasLidas / TotalPaginas * 100, 1) : 0;
}

public class CreateLivroDto
{
    [Required]
    [StringLength(300)]
    public string Titulo { get; set; } = string.Empty;

    [StringLength(200)]
    public string? Autor { get; set; }

    [StringLength(100)]
    public string? Genero { get; set; }

    [Required]
    [Range(1, int.MaxValue)]
    public int TotalPaginas { get; set; }
}

public class UpdateLivroDto
{
    [StringLength(300)]
    public string? Titulo { get; set; }

    [StringLength(200)]
    public string? Autor { get; set; }

    [StringLength(100)]
    public string? Genero { get; set; }

    [Range(1, int.MaxValue)]
    public int? TotalPaginas { get; set; }
}
