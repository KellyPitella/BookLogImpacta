using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;
using BookLog.DTOs;
using BookLog.Services;

namespace BookLog.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class LivrosController : ControllerBase
{
    private readonly LivroService _livroService;

    public LivrosController(LivroService livroService)
    {
        _livroService = livroService;
    }

    private int GetUsuarioId()
    {
        return int.Parse(
            User.FindFirst(ClaimTypes.NameIdentifier)!.Value
        );
    }

    [HttpGet]
    public async Task<IActionResult> GetLivros()
    {
        var livros = await _livroService.GetLivrosPorUsuario(GetUsuarioId());

        return Ok(livros);
    }

    [HttpPost]
    public async Task<IActionResult> CreateLivro(
        [FromBody] CreateLivroDto dto)
    {
        var livro = await _livroService.CreateLivro(
            dto,
            GetUsuarioId()
        );

        return CreatedAtAction(
            nameof(GetLivros),
            livro
        );
    }
}