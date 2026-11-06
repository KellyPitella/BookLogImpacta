using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using BookLog.DTOs;
using BookLog.Services;

namespace BookLog.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class ProgressoController : ControllerBase
{
    private readonly ProgressoService _progressoService;

    public ProgressoController(ProgressoService progressoService)
    {
        _progressoService = progressoService;
    }

    private int GetUsuarioId() => int.Parse(
        User.FindFirst(ClaimTypes.NameIdentifier)!.Value);

    [HttpPost]
    public async Task<IActionResult> Registrar([FromBody] CreateProgressoDto dto)
    {
        try
        {
            var progresso = await _progressoService.Registrar(dto, GetUsuarioId());
            if (progresso is null)
            {
                return NotFound(new { message = "Livro não encontrado." });
            }

            return Ok(progresso);
        }
        catch (ArgumentException error)
        {
            return BadRequest(new { message = error.Message });
        }
    }

    [HttpGet("livro/{livroId:int}")]
    public async Task<IActionResult> GetPorLivro(int livroId)
    {
        var progressos = await _progressoService.GetPorLivro(
            livroId,
            GetUsuarioId());

        return progressos is null ? NotFound() : Ok(progressos);
    }

    [HttpGet("resumo")]
    public async Task<ActionResult<ResumoLeituraDto>> GetResumo()
    {
        return Ok(await _progressoService.GetResumo(GetUsuarioId()));
    }

    [HttpGet("estatisticas")]
    public async Task<ActionResult<EstatisticasLeituraDto>> GetEstatisticas(
        [FromQuery] int? ano)
    {
        var anoSelecionado = ano ?? DateTime.UtcNow.Year;
        if (anoSelecionado < 1 || anoSelecionado > 9998)
        {
            return BadRequest(new { message = "Ano inválido." });
        }

        return Ok(await _progressoService.GetEstatisticas(
            anoSelecionado,
            GetUsuarioId()));
    }
}