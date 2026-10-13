using System.ComponentModel.DataAnnotations;

namespace BookLog.DTOs;

public class ProgressoLeituraDto
{
    public int Id { get; set; }
    public DateTime Data { get; set; }
    public int PaginasLidas { get; set; }
    public string? Nota { get; set; }
    public int LivroId { get; set; }
    public string? LivroTitulo { get; set; }
}

public class CreateProgressoDto
{
    [Required]
    public DateTime Data { get; set; }

    [Required]
    [Range(1, int.MaxValue, ErrorMessage = "O número de páginas deve ser maior que zero")]
    public int PaginasLidas { get; set; }

    [StringLength(500)]
    public string? Nota { get; set; }

    [Required]
    public int LivroId { get; set; }
}

public class ResumoLeituraDto
{
    public int TotalLivros { get; set; }
    public int LivrosConcluidos { get; set; }
    public int TotalPaginasLidas { get; set; }
    public int LivrosEmAndamento { get; set; }
    public List<ProgressoLeituraDto> UltimosRegistros { get; set; } = new();
}
