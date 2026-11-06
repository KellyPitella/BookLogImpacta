using Microsoft.EntityFrameworkCore;
using BookLog.Data;
using BookLog.DTOs;
using BookLog.Models;

namespace BookLog.Services;

public class LivroService
{
    private readonly BookLogContext _context;

    public LivroService(BookLogContext context)
    {
        _context = context;
    }

    public async Task<List<LivroDto>> GetLivrosPorUsuario(int usuarioId)
    {
        return await _context.Livros
            .Where(l => l.UsuarioId == usuarioId)
            .Select(l => new LivroDto
            {
                Id = l.Id,
                Titulo = l.Titulo,
                Autor = l.Autor,
                Genero = l.Genero,
                TotalPaginas = l.TotalPaginas,
                PaginasLidas = l.PaginasLidas,
                Concluido = l.Concluido,
                DataCadastro = l.DataCadastro
            })
            .OrderByDescending(l => l.DataCadastro)
            .ToListAsync();
    }

    public async Task<LivroDto> CreateLivro(
        CreateLivroDto dto,
        int usuarioId)
    {
        var livro = new Livro
        {
            Titulo = dto.Titulo,
            Autor = dto.Autor,
            Genero = dto.Genero,
            TotalPaginas = dto.TotalPaginas,
            UsuarioId = usuarioId
        };

        _context.Livros.Add(livro);

        await _context.SaveChangesAsync();

        return new LivroDto
        {
            Id = livro.Id,
            Titulo = livro.Titulo,
            Autor = livro.Autor,
            Genero = livro.Genero,
            TotalPaginas = livro.TotalPaginas,
            PaginasLidas = livro.PaginasLidas,
            Concluido = livro.Concluido,
            DataCadastro = livro.DataCadastro
        };
    }

    public async Task<LivroDto?> UpdateLivro(
        int livroId,
        UpdateLivroDto dto,
        int usuarioId)
    {
        var livro = await _context.Livros.FirstOrDefaultAsync(
            item => item.Id == livroId && item.UsuarioId == usuarioId);

        if (livro is null) return null;

        var totalPaginas = dto.TotalPaginas ?? livro.TotalPaginas;
        if (totalPaginas < livro.PaginasLidas)
        {
            throw new ArgumentException(
                "O total de páginas não pode ser menor que as páginas já lidas.");
        }

        livro.Titulo = dto.Titulo ?? livro.Titulo;
        livro.Autor = dto.Autor;
        livro.Genero = dto.Genero;
        livro.TotalPaginas = totalPaginas;
        livro.Concluido = livro.PaginasLidas >= livro.TotalPaginas;

        await _context.SaveChangesAsync();

        return new LivroDto
        {
            Id = livro.Id,
            Titulo = livro.Titulo,
            Autor = livro.Autor,
            Genero = livro.Genero,
            TotalPaginas = livro.TotalPaginas,
            PaginasLidas = livro.PaginasLidas,
            Concluido = livro.Concluido,
            DataCadastro = livro.DataCadastro
        };
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