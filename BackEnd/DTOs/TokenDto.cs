namespace BookLog.DTOs;

public class TokenDto
{
    public string Token { get; set; } = string.Empty;

    public DateTime Expiracao { get; set; }

    public UsuarioDto Usuario { get; set; } = null!;
}