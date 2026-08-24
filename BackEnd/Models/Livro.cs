using System.ComponentModel.DataAnnotations;

namespace BookLog.Models;

public class Livro
{
    [Key]
    public int Id { get; set; }

    [Required]
    [StringLength(300)]
    public string Titulo { get; set; } = string.Empty;

    [StringLength(200)]
    public string? Autor { get; set; }

    [StringLength(100)]
    public string? Genero { get; set; }

    public int TotalPaginas { get; set; }

    public DateTime DataCadastro { get; set; } = DateTime.UtcNow;

    public int UsuarioId { get; set; }

    public Usuario Usuario { get; set; } = null!;
}