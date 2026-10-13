using System.ComponentModel.DataAnnotations;

namespace BookLog.Models;

public class ProgressoLeitura
{
    [Key]
    public int Id { get; set; }

    [Required]
    public DateTime Data { get; set; }

    [Required]
    [Range(1, int.MaxValue)]
    public int PaginasLidas { get; set; }

    [StringLength(500)]
    public string? Nota { get; set; }

    public int LivroId { get; set; }
    public Livro Livro { get; set; } = null!;
}
