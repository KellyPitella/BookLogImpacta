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

    [HttpPut("{id:int}")]
    public async Task<IActionResult> UpdateLivro(
        int id,
        [FromBody] UpdateLivroDto dto)
    {
        try
        {
            var livro = await _livroService.UpdateLivro(
                id,
                dto,
                GetUsuarioId()
            );

            return livro is null ? NotFound() : Ok(livro);
        }
        catch (ArgumentException error)
        {
            return BadRequest(new { message = error.Message });
        }
    }

    [HttpDelete("{id:int}")]
    public async Task<IActionResult> DeleteLivro(int id)
    {
        var deleted = await _livroService.DeleteLivro(id, GetUsuarioId());

        return deleted ? NoContent() : NotFound();
    }
}