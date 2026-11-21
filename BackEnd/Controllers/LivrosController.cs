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
    public async Task<IActionResult> GetLivros(
        [FromQuery] string? status,
        [FromQuery] bool? favoritos,
        CancellationToken cancellationToken)
    {
        try
        {
            var livros = await _livroService.GetLivrosPorUsuario(
                GetUsuarioId(), status, favoritos, cancellationToken);
            return Ok(livros);
        }
        catch (ArgumentException error)
        {
            return BadRequest(new { message = error.Message });
        }
    }

    [HttpPost]
    public async Task<IActionResult> CreateLivro(
        [FromBody] CreateLivroDto dto)
    {
        try
        {
            var livro = await _livroService.CreateLivro(dto, GetUsuarioId());
            return CreatedAtAction(nameof(GetLivros), livro);
        }
        catch (ArgumentException error)
        {
            return BadRequest(new { message = error.Message });
        }
    }

    /// <summary>Alterna o favorito de um livro da estante do usuário.</summary>
    [HttpPatch("{id:int}/favorito")]
    [ProducesResponseType(typeof(LivroDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> ToggleFavorito(int id, CancellationToken cancellationToken)
    {
        var livro = await _livroService.ToggleFavorito(id, GetUsuarioId(), cancellationToken);
        return livro is null ? NotFound() : Ok(livro);
    }

    /// <summary>Atualiza o status de leitura de um livro da estante do usuário.</summary>
    [HttpPatch("{id:int}/status")]
    [ProducesResponseType(typeof(LivroDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> UpdateStatus(
        int id, [FromBody] UpdateLivroStatusDto dto, CancellationToken cancellationToken)
    {
        try
        {
            var livro = await _livroService.UpdateStatus(id, dto.Status, GetUsuarioId(), cancellationToken);
            return livro is null ? NotFound() : Ok(livro);
        }
        catch (ArgumentException error)
        {
            return BadRequest(new { message = error.Message });
        }
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