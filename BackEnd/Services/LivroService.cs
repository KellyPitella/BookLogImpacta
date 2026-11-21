using System.Linq.Expressions;
using Microsoft.EntityFrameworkCore;
using BookLog.Data;
using BookLog.DTOs;
using BookLog.Models;

namespace BookLog.Services;

public class LivroService
{
    private readonly BookLogContext _context;

    private static readonly Expression<Func<Livro, LivroDto>> LivroProjection = livro => new LivroDto
    {
        Id = livro.Id,
        Titulo = livro.Titulo,
        Autor = livro.Autor,
        Genero = livro.Genero,
        TotalPaginas = livro.TotalPaginas,
        PaginasLidas = livro.PaginasLidas,
        Concluido = livro.Concluido,
        Favorito = livro.Favorito,
        Status = livro.Status,
        DataCadastro = livro.DataCadastro
    };

    private static readonly Func<Livro, LivroDto> ToDto = LivroProjection.Compile();

    public LivroService(BookLogContext context)
    {
        _context = context;
    }

    public async Task<List<LivroDto>> GetLivrosPorUsuario(
        int usuarioId, string? status = null, bool? apenasFavoritos = null,
        CancellationToken cancellationToken = default)
    {
        if (status is not null) LivroStatus.Validate(status);

        var livros = _context.Livros.Where(livro => livro.UsuarioId == usuarioId);
        if (status is not null)
            livros = livros.Where(livro => livro.Status == status);
        if (apenasFavoritos == true)
            livros = livros.Where(livro => livro.Favorito);

        return await livros
            .OrderByDescending(livro => livro.DataCadastro)
            .Select(LivroProjection)
            .ToListAsync(cancellationToken);
    }

    public async Task<LivroDto> CreateLivro(CreateLivroDto dto, int usuarioId)
    {
        var livro = new Livro
        {
            Titulo = dto.Titulo,
            Autor = dto.Autor,
            Genero = dto.Genero,
            TotalPaginas = dto.TotalPaginas,
            Favorito = dto.Favorito ?? false,
            UsuarioId = usuarioId
        };
        LivroStatus.Apply(livro, dto.Status ?? LivroStatus.FromProgress(livro));

        _context.Livros.Add(livro);
        await _context.SaveChangesAsync();
        return ToDto(livro);
    }

    public async Task<LivroDto?> UpdateLivro(int livroId, UpdateLivroDto dto, int usuarioId)
    {
        if (dto.Status is not null) LivroStatus.Validate(dto.Status);

        var livro = await _context.Livros.FirstOrDefaultAsync(
            item => item.Id == livroId && item.UsuarioId == usuarioId);
        if (livro is null) return null;

        var totalPaginas = dto.TotalPaginas ?? livro.TotalPaginas;
        if (totalPaginas < livro.PaginasLidas)
        {
            throw new ArgumentException(
                "O total de páginas não pode ser menor que as páginas já lidas.");
        }

        var totalChanged = totalPaginas != livro.TotalPaginas;
        livro.Titulo = dto.Titulo ?? livro.Titulo;
        livro.Autor = dto.Autor;
        livro.Genero = dto.Genero;
        livro.TotalPaginas = totalPaginas;
        livro.Favorito = dto.Favorito ?? livro.Favorito;
        if (dto.Status is not null)
        {
            LivroStatus.Apply(livro, dto.Status);
        }
        else if (totalChanged)
        {
            livro.Concluido = livro.PaginasLidas >= livro.TotalPaginas;
            livro.Status = LivroStatus.FromProgress(livro);
        }

        await _context.SaveChangesAsync();
        return ToDto(livro);
    }

    public async Task<LivroDto?> ToggleFavorito(
        int livroId, int usuarioId, CancellationToken cancellationToken = default)
    {
        var livro = await _context.Livros.FirstOrDefaultAsync(
            item => item.Id == livroId && item.UsuarioId == usuarioId, cancellationToken);
        if (livro is null) return null;

        livro.Favorito = !livro.Favorito;
        await _context.SaveChangesAsync(cancellationToken);
        return ToDto(livro);
    }

    public async Task<LivroDto?> UpdateStatus(
        int livroId, string novoStatus, int usuarioId, CancellationToken cancellationToken = default)
    {
        LivroStatus.Validate(novoStatus);
        var livro = await _context.Livros.FirstOrDefaultAsync(
            item => item.Id == livroId && item.UsuarioId == usuarioId, cancellationToken);
        if (livro is null) return null;

        LivroStatus.Apply(livro, novoStatus);
        await _context.SaveChangesAsync(cancellationToken);
        return ToDto(livro);
    }

    public async Task<bool> DeleteLivro(int livroId, int usuarioId)
    {
        var livro = await _context.Livros.FirstOrDefaultAsync(
            item => item.Id == livroId && item.UsuarioId == usuarioId);
        if (livro is null) return false;

        _context.Livros.Remove(livro);
        await _context.SaveChangesAsync();
        return true;
    }
}
